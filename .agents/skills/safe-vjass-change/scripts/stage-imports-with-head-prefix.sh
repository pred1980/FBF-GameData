#!/usr/bin/env bash
# Stages src/imports.j for a commit with the path prefix that HEAD uses, while
# the working copy keeps its local checkout prefix. The working tree is never
# modified; only the index entry for src/imports.j is replaced.
#
# Every import path is resolved structurally with resolve-imports.awk: the
# prefix is the part before the "\src\" after which the rest names an existing
# file, so a checkout under a path such as C:\src\FBF works. The staged version
# is then compared with HEAD line by line, without git diff, so the result does
# not depend on diff.algorithm or other diff settings. It may differ from HEAD
# only by added import lines that point at existing files under src/, and by
# removed import lines. The index is written only after every check passed; if
# a check fails, the script exits with 1 and the index stays exactly as it was.
#
# Usage (with Git Bash on Windows):
#   bash .agents/skills/safe-vjass-change/scripts/stage-imports-with-head-prefix.sh
# Undo:
#   git restore --staged src/imports.j

set -eu
script_dir=$(cd "$(dirname "$0")" && pwd)
cd "$(git rev-parse --show-toplevel)"
f=src/imports.j
resolve="$script_dir/resolve-imports.awk"

refuse() {
	printf '%s\n' "$@" >&2
	echo "Nothing was staged; the index is unchanged." >&2
	exit 1
}

[ -f "$resolve" ] || refuse "Helper $resolve is missing."
git cat-file -e "HEAD:$f" 2> /dev/null || refuse "$f is missing in HEAD."
[ -f "$f" ] || refuse "$f is missing in the working copy."
[ -z "$(git ls-files -u -- "$f")" ] || refuse "$f has unresolved merge conflicts."
old_entry=$(git ls-files -s -- "$f")
[ -n "$old_entry" ] || refuse "$f is not in the index."
mode=$(printf '%s\n' "$old_entry" | cut -d' ' -f1)
old_blob=$(printf '%s\n' "$old_entry" | cut -d' ' -f2)

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# Files that exist in HEAD and in the working tree, as repository paths.
git ls-tree -r --name-only HEAD -- src > "$tmp/head-files"
git ls-files --cached --others --exclude-standard -- src | while IFS= read -r p; do
	[ -f "$p" ] && printf '%s\n' "$p"
done > "$tmp/work-files"

git show "HEAD:$f" > "$tmp/head"
awk -f "$resolve" "$tmp/head-files" "$tmp/head" > "$tmp/head-res"
awk -f "$resolve" "$tmp/work-files" "$f" > "$tmp/work-res"

# Lists the import lines that did not resolve, for an error message.
unresolved() {
	awk -F'\t' '
		$1 == "NONE"  { print "        line " $2 ": " $3 "  (no existing file under src/)" }
		$1 == "AMBIG" { print "        line " $2 ": " $3 "  (ambiguous: several files under src/ match)" }
	' "$1"
}

if grep -qv '^OK' "$tmp/head-res"; then
	refuse "These import lines in HEAD:$f do not resolve to exactly one file:" "$(unresolved "$tmp/head-res")"
fi
if grep -qv '^OK' "$tmp/work-res"; then
	refuse "These import lines in the working copy of $f do not resolve to exactly one file:" \
		"$(unresolved "$tmp/work-res")" "Fix them, then run this script again."
fi
head_prefix=$(cut -f3 "$tmp/head-res" | sort -u)
work_prefix=$(cut -f3 "$tmp/work-res" | sort -u)
if [ -z "$head_prefix" ] || [ -z "$work_prefix" ]; then
	refuse "No import prefix found in HEAD or in the working copy of $f."
fi
if [ "$(printf '%s\n' "$head_prefix" | wc -l)" -ne 1 ] || [ "$(printf '%s\n' "$work_prefix" | wc -l)" -ne 1 ]; then
	refuse "HEAD or the working copy of $f mixes path prefixes." \
		"HEAD:" "$(printf '%s\n' "$head_prefix" | sed 's/^/        /')" \
		"Working copy:" "$(printf '%s\n' "$work_prefix" | sed 's/^/        /')" \
		"Give every import line in the working copy the same prefix, then run this script again."
fi
if [ "$head_prefix" = "$work_prefix" ]; then
	echo "Prefixes already match ($head_prefix); stage normally with: git add $f"
	exit 0
fi

# Rewrite each resolved import path to <HEAD prefix>\src\<rel>; keep everything else.
TO="$head_prefix" awk '
	FNR == NR { split($0, a, "\t"); rel[a[2]] = a[4]; next }
	(FNR in rel) {
		cr = sub(/\r$/, "")
		match($0, /^[[:space:]]*\/\/! import "/)
		start = substr($0, 1, RLENGTH)
		rest = substr($0, RLENGTH + 1)
		$0 = start ENVIRON["TO"] "\\src\\" rel[FNR] substr(rest, index(rest, "\""))
		if (cr) $0 = $0 "\r"
	}
	{ print }
' "$tmp/work-res" "$f" > "$tmp/staged"
# awk always ends the last line with a newline; keep the file's original ending.
if [ -n "$(tail -c 1 "$f" | tr -d '\r\n')" ]; then
	size=$(wc -c < "$tmp/staged")
	head -c $((size - 1)) "$tmp/staged" > "$tmp/staged.eof" && mv "$tmp/staged.eof" "$tmp/staged"
fi

# --path applies the same attributes and line-ending conversion as git add.
# The object is written, but the index is not touched yet.
blob=$(git -c core.safecrlf=false hash-object -w --path="$f" "$tmp/staged")
git cat-file blob "$blob" > "$tmp/staged-blob"

# Compare with HEAD as sequences of lines, independent of any diff algorithm.
# Added and removed lines must be import lines; all other lines must stay in
# the same order.
awk '
	function is_import(l) { return l ~ /^[[:space:]]*\/\/! import "[^"]*"$/ }
	FNR == NR { sub(/\r$/, ""); h[++nh] = $0; hc[$0]++; next }
	{ sub(/\r$/, ""); s[++ns] = $0; sc[$0]++ }
	END {
		for (l in sc) if (sc[l] > ((l in hc) ? hc[l] : 0)) added[l] = 1
		for (l in hc) if (hc[l] > ((l in sc) ? sc[l] : 0)) removed[l] = 1
		for (l in added) print (is_import(l) ? "ADDED" : "CHANGED") "\t" l
		for (l in removed) print (is_import(l) ? "REMOVED" : "CHANGED") "\t" l
		i = 0; for (k = 1; k <= ns; k++) if (!(s[k] in added)) fs[++i] = s[k]
		j = 0; for (k = 1; k <= nh; k++) if (!(h[k] in removed)) fh[++j] = h[k]
		same = (i == j)
		for (k = 1; same && k <= i; k++) if (fs[k] != fh[k]) same = 0
		if (!same) print "ORDER\t"
	}
' "$tmp/head" "$tmp/staged-blob" > "$tmp/compare"

if grep -q '^CHANGED' "$tmp/compare"; then
	refuse "Besides import lines, $f would change these lines:" "$(grep '^CHANGED' "$tmp/compare" | cut -f2- | sed 's/^/        /')" \
		"Fix them in the working copy, then run this script again."
fi
if grep -q '^ORDER' "$tmp/compare"; then
	refuse "The working copy of $f moves or duplicates lines compared with HEAD; this script only stages added or removed import lines."
fi
# Every added import line must use the HEAD prefix and point at an existing file.
grep '^ADDED' "$tmp/compare" | cut -f2- > "$tmp/added"
awk -f "$resolve" "$tmp/work-files" "$tmp/added" > "$tmp/added-res"
bad=$(HP="$head_prefix" awk -F'\t' '$1 != "OK" || $3 != ENVIRON["HP"] { print "        " $0 }' "$tmp/added-res")
if [ -n "$bad" ] || [ "$(wc -l < "$tmp/added-res")" -ne "$(wc -l < "$tmp/added")" ]; then
	refuse "These added import lines do not resolve to an existing file with the HEAD prefix ($head_prefix):" "$bad"
fi

if [ "$blob" = "$old_blob" ]; then
	echo "The index already holds this version of $f; nothing changed."
	exit 0
fi
git update-index --cacheinfo "$mode,$blob,$f"

if [ ! -s "$tmp/added" ] && ! grep -q '^REMOVED' "$tmp/compare"; then
	echo "$f differs from HEAD only by the local prefix; the staged version equals HEAD."
	exit 0
fi
echo "Staged $f with the HEAD prefix ($head_prefix); the working copy keeps $work_prefix."
echo "Review the staged change, which must contain only your added or removed import lines: git diff --cached -- $f"
git -c core.safecrlf=false diff --cached --stat -- "$f"
