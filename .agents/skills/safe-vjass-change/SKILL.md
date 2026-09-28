---
name: safe-vjass-change
description: Safety checklist and static checks for changing Warcraft III vJASS code in Forsaken Bastion's Fall. Use before and after editing anything under src/ (.vj files or src/imports.j), including adding a .vj file, changing rawcodes or order strings, hero abilities, hero AI or shared libraries, and before reporting such a change as done.
---

# Safe vJASS change

No command can compile or run this map. The real build is a human saving the current development map `FBF_v<Version>_dev.w3x` in the repository root (`ls FBF_v*_dev.w3x` shows it; it is not the `Working copie`) in the current Warcraft III World Editor, which includes JassHelper and pJASS, with `Enable JassHelper` and `Enable vJASS` turned on. The real runtime test is a human playtest in Warcraft III. This checklist catches what static inspection can. It never replaces those two steps, and passing it is no evidence that the map compiles.

Run the commands from the repository root in Git Bash.

## 1. Before editing a file

Check its encoding with `file <path>`. "ISO-8859 text" means Windows-1252; "UTF-8" and "ASCII" are safe to edit directly.

**Never edit a Windows-1252 file in place with a tool that reads files as UTF-8.** Claude Code's Edit tool does exactly that: in a test it replaced `ü` (byte `0xFC`) with U+FFFD and saved the whole file as UTF-8. Treat other agent edit tools the same way unless proven otherwise. Edit such a file through a UTF-8 copy outside the repository:

```bash
iconv -f WINDOWS-1252 -t UTF-8 src/Path/File.vj > "${TMPDIR:-/tmp}/File.utf8.vj"
# edit the copy with your normal tool, then convert it back:
iconv -f UTF-8 -t WINDOWS-1252 "${TMPDIR:-/tmp}/File.utf8.vj" > src/Path/File.vj
```

The second `iconv` fails on characters that Windows-1252 cannot represent, so keep new text ASCII.

Line endings: the index stores LF (`* text=auto`), and checkouts with `core.autocrlf=true` (the Windows setup here) have CRLF working files. In Git Bash, rewriting a file with `sed -i` or `awk` silently drops the CRs. Git normalizes on commit, so the diff stays clean, but a file must not end up with mixed endings. `unix2dos <file>` turns an LF-only file back into CRLF.

## 2. Find everything the change touches

| You change | Search | Why |
|---|---|---|
| A rawcode such as `'A07K'` | `git grep -n "'A07K'" -- src` | The object itself lives in the `.w3x`. The same rawcode can appear in the ability, in its hero AI (spell ID, learnset) and in item or tower systems. |
| An order string such as `"roar"` | `git grep -n '"roar"' -- src` | The hero AI issues orders by string, and abilities detect channeling with `GetUnitCurrentOrder(u) == OrderId(ORDER_ID)`. The string must match the ability's order in the Object Editor, which the repo cannot show. Numeric order IDs (for example `851983`, attack, in `HeroAI.vj`) need their own search. |
| A hero ability in `src/Heroes/<Hero>/<Ability>.vj` | open `src/AI-Systems/HeroesAI/<Hero>AI.vj` (for the Behemoth: `BehemotAI.vj`) | The AI repeats the spell ID, order string, radii and cooldowns; for example `F_RADIUS` in `ArchmageAI.vj` mirrors `RAIN_AOE` in `Fireworks.vj`. Change both or neither. |
| A library `X` | `git grep -nw X -- src`, then `git grep -nw <name> -- src` for each public function, struct or module you change | Consumers include `optional` requirements, `implement` of modules and `//! runtextmacro` of textmacros. `requires` lists can continue over several lines inside `/* … */`, so searching for `requires X` misses consumers; for example `HeroAI.vj` declares `optional FitnessFunc` on a continuation line. |
| A `public` member of a scope or library | `git grep -nw 'ScopeName_member' -- src` as well as the bare name | Outside its scope, a public member is referenced as `ScopeName_member`, for example `HeroAI_SIGHT_RANGE`. |
| Any struct, function or global | `git grep -nw <Name> -- src` | vJASS has no namespaces beyond scope and library prefixes. |

Cooldowns, mana costs, ranges and tooltips live in the Object Editor. When the code mirrors such a value, list it in the PR as a manual check.

## 3. Adding a new `.vj` file

- Add `//! import "<prefix>\src\<Dir>\<File>.vj"` to `src/imports.j` under the matching section comment, with exactly the prefix the other lines use. A file that is not imported there is not compiled.
- A `library` must declare every library it uses with `requires`; a `scope` can use any library. JassHelper orders libraries by these declarations, not by their position in `imports.j`.
- Keep the file ASCII-only (write German umlauts in comments as `ae`, `oe`, `ue` and `ss`), and follow the `scope`/`library`, `struct`, `private` and PascalCase naming conventions in `AGENTS.md`.

### `imports.j` with a local path prefix

`src/imports.j` holds machine-specific absolute paths. If your working copy uses a different prefix from `HEAD` (the check script warns about this), the prefix is a local setting and must not be committed. To commit only your new lines, with the prefix from `HEAD`:

```bash
bash .agents/skills/safe-vjass-change/scripts/stage-imports-with-head-prefix.sh
git diff --cached -- src/imports.j   # must show only your added or removed import lines
```

The script replaces only the index entry; the working copy keeps its local prefix. It resolves every import path structurally with `scripts/resolve-imports.awk`: the prefix is the part before the `\src\` after which the rest names an existing file, so a checkout under a path such as `C:\src\FBF` works. It then compares the result with `HEAD` line by line, without `git diff`, so `diff.algorithm` and other diff settings do not affect it. The index is written only after every check passed. The script stages nothing, leaves the index exactly as it was, exits with 1 and lists the offending lines when it cannot determine a safe result: when an import line resolves to no file or to several files under `src/`, when `HEAD` or the working copy mixes prefixes, when `src/imports.j` has merge conflicts, or when the staged version would differ from `HEAD` by anything other than added import lines that point at existing files and removed import lines (for example an edited comment, or moved or duplicated lines). If the working copy already uses the `HEAD` prefix, it stages nothing and tells you to use `git add src/imports.j`. Undo a successful run with `git restore --staged src/imports.j`. After that, stage your other files by name, never with `git add -A` or `git add src/imports.j`, because both would stage the local prefix.

Do not convert the paths to relative paths or any other scheme: no alternative has been verified to work with JassHelper.

## 4. Never touch the map file

Do not edit, regenerate, re-save, rename, add or delete any `.w3x` with tools. If a change needs Object Editor data (a new ability, unit, rawcode, tooltip, cooldown or order string), implement only the code and list the exact Object Editor changes in the PR for a human.

## 5. Static checks after editing

```bash
bash .agents/skills/safe-vjass-change/scripts/check-vjass-change.sh
```

The script reports a FAIL or WARN for:

- `.vj` files that are not in `src/imports.j`, and imports that point at no file or ambiguously at several files (the two knowingly unimported files are only noted). Import paths are resolved with `scripts/resolve-imports.awk` like in the staging script, so a checkout path that contains `\src\` is no problem;
- mixed import prefixes, a prefix that differs from `HEAD`, or a prefix that does not point at this checkout;
- any changed, added or deleted `.w3x`;
- changed or new files under `src/` whose encoding changed (Windows-1252 ↔ UTF-8), that gained a UTF-8 BOM, or that have mixed line endings;
- whitespace errors from `git diff --check`.

Exit code 1 means at least one FAIL; fix it before committing. Then read `git diff` yourself: only the intended lines changed, nothing reformatted, umlauts intact.

## 6. Manual verification to request

List in the PR what a human has to do:

1. **Compile:** open the current development map `FBF_v<Version>_dev.w3x` in the World Editor with JassHelper and vJASS enabled, save, and report any JassHelper or pJASS errors. The tester's `src/imports.j` must point at their checkout.
2. **Playtest:** name concrete scenarios: faction, hero, ability and level, the difficulty of computer slots (easy/normal/insane) when hero AI is involved, the game mode (`-ap` or `-ar`), and what to watch for.
3. **Object Editor:** list the values the code mirrors or requires.

`IS_DEBUG_MODE` in `src/GameConfig/GameConfig.vj` shortens the hero-pick and round timers for testing. Never commit it as `true`.

Until a human reports results, state that the change has not been compiled or playtested.
