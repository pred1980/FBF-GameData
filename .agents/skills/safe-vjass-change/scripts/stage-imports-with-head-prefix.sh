#!/usr/bin/env bash
# Stages src/imports.j for a commit with the path prefix that HEAD uses, while
# the working copy keeps its local checkout prefix. The working tree is not
# modified; only the index entry for src/imports.j is replaced.
#
# The staged version may differ from HEAD only by added or removed import lines
# with the HEAD prefix. If it would contain anything else, for example a path
# that still points at the local checkout, the script restores the previous
# index entry and exits with 1.
#
# Usage (with Git Bash on Windows):
#   bash .agents/skills/safe-vjass-change/scripts/stage-imports-with-head-prefix.sh
# Undo:
#   git restore --staged src/imports.j

set -eu
cd "$(git rev-parse --show-toplevel)"
f=src/imports.j

prefix_of() {
	tr -d '\r' | sed -n 's/^[[:space:]]*\/\/! import "\(.*\)".*$/\1/p' |
		awk '{ i = index($0, "\\src\\"); if (i) print substr($0, 1, i - 1) }' | sort -u
}

if ! git cat-file -e "HEAD:$f" 2> /dev/null || [ ! -f "$f" ]; then
	echo "$f is missing in HEAD or in the working copy; nothing was staged." >&2
	exit 1
fi
if [ -n "$(git ls-files -u -- "$f")" ]; then
	echo "$f has unresolved merge conflicts; nothing was staged." >&2
	exit 1
fi
old_entry=$(git ls-files -s -- "$f")
if [ -z "$old_entry" ]; then
	echo "$f is not in the index; nothing was staged." >&2
	exit 1
fi
mode=$(printf '%s\n' "$old_entry" | cut -d' ' -f1)
old_blob=$(printf '%s\n' "$old_entry" | cut -d' ' -f2)

head_prefix=$(git show "HEAD:$f" | prefix_of)
work_prefix=$(prefix_of < "$f")
if [ -z "$head_prefix" ] || [ -z "$work_prefix" ]; then
	echo "No import prefix found in HEAD or in the working copy of $f; nothing was staged." >&2
	exit 1
fi
if [ "$(printf '%s\n' "$head_prefix" | wc -l)" -ne 1 ] || [ "$(printf '%s\n' "$work_prefix" | wc -l)" -ne 1 ]; then
	echo "HEAD or the working copy of $f mixes path prefixes; nothing was staged." >&2
	echo "Give every import line in the working copy the same prefix, then run this script again." >&2
	exit 1
fi
if [ "$head_prefix" = "$work_prefix" ]; then
	echo "Prefixes already match ($head_prefix); stage normally with: git add $f"
	exit 0
fi

tmp=$(mktemp)
trap 'rm -f "$tmp" "$tmp.eof"' EXIT
# Literal replacement via ENVIRON (awk -v would interpret the backslashes).
FROM="$work_prefix" TO="$head_prefix" awk '
	BEGIN { from = ENVIRON["FROM"] "\\src\\"; to = ENVIRON["TO"] "\\src\\" }
	{ i = index($0, from); if (i) $0 = substr($0, 1, i - 1) to substr($0, i + length(from)); print }
' "$f" > "$tmp"
# awk always ends the last line with a newline; keep the file's original ending.
if [ -n "$(tail -c 1 "$f" | tr -d '\r\n')" ]; then
	size=$(wc -c < "$tmp")
	head -c $((size - 1)) "$tmp" > "$tmp.eof" && mv "$tmp.eof" "$tmp"
fi

# --path applies the same attributes and line-ending conversion as git add.
blob=$(git -c core.safecrlf=false hash-object -w --path="$f" "$tmp")
git update-index --cacheinfo "$mode,$blob,$f"

# Every added or removed line must be an import line with the HEAD prefix.
bad=$(git -c core.safecrlf=false diff --cached --no-color --no-ext-diff -U0 -- "$f" |
	HP="$head_prefix" awk '
		BEGIN { want = "//! import \"" ENVIRON["HP"] "\\src\\" }
		/^@@/ { inhunk = 1; next }
		!inhunk { next }
		/^[+-]/ {
			line = substr($0, 2); sub(/\r$/, "", line); sub(/^[[:space:]]+/, "", line)
			if (index(line, want) != 1) print "        " $0
		}
	')
if [ -n "$bad" ]; then
	git update-index --cacheinfo "$mode,$old_blob,$f"
	echo "Not staged: besides import lines with the HEAD prefix ($head_prefix), $f would change these lines:" >&2
	printf '%s\n' "$bad" >&2
	echo "The previous index entry of $f was restored. Fix these lines in the working copy, then run this script again." >&2
	exit 1
fi
if git -c core.safecrlf=false diff --cached --quiet -- "$f"; then
	echo "$f differs from HEAD only by the local prefix; nothing of it is staged."
	exit 0
fi

echo "Staged $f with the HEAD prefix ($head_prefix); the working copy keeps $work_prefix."
echo "Review the staged change, which must contain only your new lines: git diff --cached -- $f"
git -c core.safecrlf=false diff --cached --stat -- "$f"
