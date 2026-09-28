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
cd "$(git rev-parse --show-toplevel)" || exit 2

IMPORTS=src/imports.j
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

# Reads imports.j content on stdin, prints "prefix|src/relative/path" per import.
parse_imports() {
	tr -d '\r' | sed -n 's/^[[:space:]]*\/\/! import "\(.*\)".*$/\1/p' | awk '{
		i = index($0, "\\src\\")
		if (i == 0) { print "?|" $0; next }
		rel = substr($0, i + 5); gsub(/\\/, "/", rel)
		print substr($0, 1, i - 1) "|src/" rel
	}'
}

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

# 1. imports.j path prefix
work_imports=$(parse_imports < "$IMPORTS")
prefixes=$(printf '%s\n' "$work_imports" | cut -d'|' -f1 | sort -u)
if [ "$(printf '%s\n' "$prefixes" | wc -l)" -ne 1 ]; then
	fail "$IMPORTS mixes path prefixes:"; printf '        %s\n' $prefixes
else
	ok "$IMPORTS uses one path prefix: $prefixes"
	head_prefixes=$(git show "HEAD:$IMPORTS" 2> /dev/null | parse_imports | cut -d'|' -f1 | sort -u)
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
files=$(git ls-files --cached --others --exclude-standard -- 'src/*.vj' | while IFS= read -r f; do
	[ -f "$f" ] && printf '%s\n' "$f"
done)
import_check=$(awk -v known="$KNOWN_UNIMPORTED" '
	BEGIN { n = split(tolower(known), k, "\n"); for (i = 1; i <= n; i++) if (k[i] != "") isknown[k[i]] = 1 }
	FNR == NR { if ($0 != "") imp[tolower($0)] = $0; next }
	$0 != "" {
		key = tolower($0)
		if (key in imp) seen[key] = 1
		else if (key in isknown) print "KNOWN " $0
		else print "MISSING " $0
	}
	END { for (key in imp) if (!(key in seen)) print "DANGLING " imp[key] }
' <(printf '%s\n' "$work_imports" | cut -d'|' -f2) <(printf '%s\n' "$files"))
missing=0
while IFS=' ' read -r kind path; do
	case $kind in
		MISSING)  fail "not imported in $IMPORTS: $path"; missing=1 ;;
		DANGLING) fail "imported but not found: $path"; missing=1 ;;
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
