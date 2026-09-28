#!/usr/bin/env bash
# Static checks for vJASS changes in Forsaken Bastion's Fall.
#
# Usage (from anywhere inside the repository, with Git Bash on Windows):
#   bash .agents/skills/safe-vjass-change/scripts/check-vjass-change.sh
#
# These checks cannot compile the map. Saving the map in the World Editor with
# JassHelper and vJASS enabled, and a Warcraft III playtest, stay manual steps.
# Exit code: 0 = no failures, 1 = at least one FAIL.

set -u
script_dir=$(cd "$(dirname "$0")" && pwd)
cd "$(git rev-parse --show-toplevel)" || exit 2

IMPORTS=src/imports.j
# Resolves import paths structurally; a checkout path may itself contain "\src\".
RESOLVE="$script_dir/resolve-imports.awk"
# .vj files that are knowingly not imported (see CLAUDE.md, "Dateien beim Build").
KNOWN_UNIMPORTED='src/libraries/checkimmunity.vj
src/libraries/xe/beziermissiles.vj'

fails=0
fail() { printf 'FAIL  %s\n' "$*"; fails=$((fails + 1)); }
# Silences "LF will be replaced by CRLF" warnings, which are not findings.
g() { git -c core.safecrlf=false "$@"; }
warn() { printf 'WARN  %s\n' "$*"; }
ok()   { printf 'OK    %s\n' "$*"; }
note() { printf 'NOTE  %s\n' "$*"; }

if [ ! -f "$RESOLVE" ]; then echo "FAIL  helper $RESOLVE is missing"; exit 1; fi
tmpd=$(mktemp -d)
trap 'rm -rf "$tmpd"' EXIT

# Files that exist in the working tree and in HEAD, as repository paths (src/...).
git ls-files --cached --others --exclude-standard -- src | while IFS= read -r p; do
	[ -f "$p" ] && printf '%s\n' "$p"
done > "$tmpd/work-files"
git ls-tree -r --name-only HEAD -- src > "$tmpd/head-files" 2> /dev/null || : > "$tmpd/head-files"

# Prints ascii, utf-8 or legacy (not valid UTF-8, i.e. Windows-1252) for stdin.
encoding_class() {
	local tmp; tmp=$(mktemp)
	cat > "$tmp"
	if ! LC_ALL=C grep -q $'[\x80-\xFF]' "$tmp"; then echo ascii
	elif iconv -f UTF-8 -t UTF-8 "$tmp" > /dev/null 2>&1; then echo utf-8
	else echo legacy; fi
	rm -f "$tmp"
}

has_bom() { [ "$(head -c 3 | od -An -tx1 | tr -d ' \n')" = efbbbf ]; }

# 1. imports.j path prefix (taken from the import lines that resolve to a file; see step 2 for the others)
awk -f "$RESOLVE" "$tmpd/work-files" "$IMPORTS" > "$tmpd/work-res"
prefixes=$(awk -F'\t' '$1 == "OK" { print $3 }' "$tmpd/work-res" | sort -u)
nprefixes=$(printf '%s' "$prefixes" | grep -c '^')
if [ "$nprefixes" -eq 0 ]; then
	fail "$IMPORTS: no import line points at an existing file under src/"
elif [ "$nprefixes" -gt 1 ]; then
	fail "$IMPORTS mixes path prefixes:"; printf '%s\n' "$prefixes" | sed 's/^/        /'
else
	ok "$IMPORTS uses one path prefix: $prefixes"
	head_prefixes=$(git show "HEAD:$IMPORTS" 2> /dev/null | awk -f "$RESOLVE" "$tmpd/head-files" - |
		awk -F'\t' '$1 == "OK" { print $3 }' | sort -u)
	if [ -n "$head_prefixes" ] && [ "$head_prefixes" != "$prefixes" ]; then
		warn "prefix differs from HEAD ($head_prefixes). A local checkout path must not be committed; see SKILL.md, \"imports.j with a local path prefix\"."
	fi
	if command -v cygpath > /dev/null 2>&1; then
		here=$(cygpath -w "$(pwd)")
		if [ "$(printf '%s' "$prefixes" | tr 'A-Z' 'a-z')" != "$(printf '%s' "$here" | tr 'A-Z' 'a-z')" ]; then
			warn "prefix does not point at this checkout ($here); the World Editor would not compile these sources here."
		fi
	fi
fi

# 2. every .vj under src/ is imported, every import exists (case-insensitive, like Windows)
missing=0
while IFS=$'\t' read -r kind line path; do
	case $kind in
		NONE)  fail "imported but not found: $path (line $line)"; missing=1 ;;
		AMBIG) fail "import path is ambiguous, several files under src/ match: $path (line $line)"; missing=1 ;;
	esac
done < "$tmpd/work-res"
import_check=$(awk -v known="$KNOWN_UNIMPORTED" '
	BEGIN { n = split(tolower(known), k, "\n"); for (i = 1; i <= n; i++) if (k[i] != "") isknown[k[i]] = 1 }
	FNR == NR { if ($1 == "OK") { key = "src/" tolower($4); gsub(/\\/, "/", key); imp[key] = 1 }; next }
	/\.vj$/ {
		key = tolower($0)
		if (key in imp) next
		if (key in isknown) print "KNOWN " $0
		else print "MISSING " $0
	}
' FS='\t' "$tmpd/work-res" FS='\n' "$tmpd/work-files")
while IFS=' ' read -r kind path; do
	case $kind in
		MISSING)  fail "not imported in $IMPORTS: $path"; missing=1 ;;
		KNOWN)    note "known unimported file: $path" ;;
	esac
done <<< "$import_check"
[ "$missing" -eq 0 ] && ok "every .vj file under src/ is imported and every import exists"

# 3. binary maps are untouched
w3x=$(git status --porcelain -- '*.w3x' '*.W3X')
if [ -n "$w3x" ]; then fail "a .w3x map file is modified, added or deleted:"; printf '        %s\n' "$w3x"
else ok "no .w3x file changed"; fi

# 4. encoding, BOM and line endings of changed source files
changed=$( { g diff --name-only --diff-filter=AMR HEAD -- src; git ls-files --others --exclude-standard -- src; } | sort -u)
count=0
before=$fails
while IFS= read -r f; do
	[ -n "$f" ] && [ -f "$f" ] || continue
	case $f in *.vj|*.j|*.txt|*.md) ;; *) continue ;; esac
	count=$((count + 1))
	work=$(encoding_class < "$f")
	if git cat-file -e "HEAD:$f" 2> /dev/null; then
		head=$(git show "HEAD:$f" | encoding_class)
		case "$head>$work" in
			legacy\>utf-8|utf-8\>legacy) fail "$f: encoding changed from $head to $work" ;;
			legacy\>ascii) warn "$f: all non-ASCII characters were removed (was Windows-1252); intended?" ;;
			ascii\>utf-8|ascii\>legacy) warn "$f: now contains non-ASCII characters ($work)" ;;
		esac
		if has_bom < "$f" && ! git show "HEAD:$f" | has_bom; then fail "$f: a UTF-8 BOM was added"; fi
	else
		[ "$work" = legacy ] && warn "$f: new file is not UTF-8 (Windows-1252); prefer ASCII"
		has_bom < "$f" && fail "$f: new file starts with a UTF-8 BOM"
	fi
	# Count bytes with tr; grep in Git Bash does not count "\r$" reliably.
	cr=$(tr -cd '\r' < "$f" | wc -c)
	lf=$(tr -cd '\n' < "$f" | wc -c)
	if [ "$cr" -gt 0 ] && [ "$cr" -lt "$lf" ]; then
		fail "$f: mixed line endings ($cr CRLF, $((lf - cr)) LF)"
	elif [ "$cr" -eq 0 ] && [ "$(git config --get core.autocrlf)" = true ]; then
		warn "$f: LF line endings, while this checkout uses CRLF (core.autocrlf=true)"
	fi
done <<< "$changed"
if [ "$count" -eq 0 ]; then note "no changed text files under src/"
elif [ "$fails" -eq "$before" ]; then ok "encoding and line endings unchanged in $count changed file(s) under src/"; fi

# 5. whitespace errors in the diff
if ws=$(g diff --check HEAD 2>&1) && [ -z "$ws" ]; then ok "git diff --check HEAD is clean"
else fail "git diff --check HEAD reports whitespace errors:"; printf '%s\n' "$ws" | sed 's/^/        /'; fi

echo
if [ "$fails" -gt 0 ]; then echo "$fails check(s) failed."; else echo "Static checks passed. Compile and playtest are still manual."; fi
[ "$fails" -eq 0 ]
