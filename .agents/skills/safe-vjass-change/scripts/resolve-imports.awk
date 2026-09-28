# Resolves the "//! import" lines of src/imports.j structurally. Shared by
# check-vjass-change.sh and stage-imports-with-head-prefix.sh.
#
# Usage: awk -f resolve-imports.awk <file-list> <imports.j or ->
#   <file-list>  repository paths (src/...) of the files that exist, one per line
#
# An import path has the form <prefix>\src\<rel>. The checkout prefix can itself
# contain "\src\" (for example C:\src\FBF), so the path is not split at the first
# "\src\". Every "\src\" in the path is tried instead, and a split counts only if
# src/<rel> is an existing file. Matching ignores case, like Windows.
#
# Prints one tab-separated line per import line:
#   OK     <line> <prefix> <rel>  exactly one split names an existing file
#   NONE   <line> <path>          no split names an existing file
#   AMBIG  <line> <path>          more than one split names an existing file
# <rel> keeps its original backslashes and case. Other lines are ignored.

FNR == NR { if ($0 != "") exists[tolower($0)] = 1; next }

{
	line = $0
	sub(/\r$/, "", line)
	if (!match(line, /^[[:space:]]*\/\/! import "[^"]*"/)) next
	path = substr(line, RSTART, RLENGTH)
	sub(/^[[:space:]]*\/\/! import "/, "", path)
	sub(/"$/, "", path)

	lower = tolower(path)
	n = 0
	for (i = 1; i + 5 <= length(path); i++) {
		if (substr(lower, i, 5) != "\\src\\") continue
		rel = substr(path, i + 5)
		key = "src/" tolower(rel)
		gsub(/\\/, "/", key)
		if (key in exists) { n++; prefix = substr(path, 1, i - 1); found = rel }
	}
	if (n == 1) printf "OK\t%d\t%s\t%s\n", FNR, prefix, found
	else if (n == 0) printf "NONE\t%d\t%s\n", FNR, path
	else printf "AMBIG\t%d\t%s\n", FNR, path
}
