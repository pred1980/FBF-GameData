---
name: implement-ticket
description: Implements one development ticket (a GitHub issue) end-to-end in this repository. Reads the ticket or issue and all its comments, creates a dedicated branch, makes the smallest sufficient change, verifies it with static checks, commits, pushes and opens a pull request that closes the issue. Then continues with the review-pr flow - reviews the PR, fixes BLOCKER, ERROR and MAJOR findings, re-reviews and merges when neither a file under src/ nor a .w3x changed; with such changes it stops before the merge until a human confirms the World Editor build and Warcraft III playtest. Use when asked to work on, implement, fix or resolve a ticket or a GitHub issue (for example "implement ticket 12" or "fix issue 12").
---

# Implement a GitHub issue

One issue = one branch = one pull request.

A request to implement an issue authorizes you to create the issue branch, commit to it, push it, open a PR and then run step 9: review the PR, fix blocking findings on the branch and, when every merge gate in `review-pr` passes, merge the PR into `master` and clean up. It never authorizes pushing to `master`, enabling auto-merge, bypassing branch protection or required reviews, fixing `MINOR` findings without an explicit request, or deciding design, balance or unclear scope.

Input: the issue number. If none was given, ask for it.

## 1. Read the issue completely

- `gh issue view <n> --comments`: read the title, body, labels and every comment. Later comments can change the scope.
- Read issues and PRs that the issue links to.
- Check for existing work: `gh pr list --state all --search "<n>"` and `git branch -a --list "*issue-<n>-*"`. If a branch or PR already exists, ask whether to continue it instead of starting over.
- Work out the acceptance criteria. Ask before writing code if the issue is ambiguous, contradicts `AGENTS.md`, or needs a decision that belongs to a human (balance values, design, scope).
- If the issue needs changes inside a `.w3x`: when it explicitly requires a direct change of the current development map, follow `.agents/skills/safe-w3x-change/SKILL.md`; otherwise say up front that you only prepare the code and a list of the editor changes for a human.

## 2. Inspect the repository state

```bash
git status --short --branch
git stash list
git fetch origin
```

Never discard, stash, reset, overwrite or commit changes you did not make. If they touch files the issue needs, stop and report them. Otherwise leave them in place: they travel with you to the new branch and stay uncommitted. A typical local change is a machine-specific path prefix in `src/imports.j`; it must never be committed (see the `safe-vjass-change` skill).

## 3. Create the branch and set the project status

```bash
git switch -c <type>/issue-<n>-<short-slug> origin/master
```

Use `feature`, `fix`, `docs` or `chore` as `<type>`, and 3–5 words from the title as a kebab-case slug, for example `docs/issue-1-vjass-build-workflow`. Never commit on `master`. If the switch fails because of local changes, stop and report.

When implementation begins, set the issue's Status in the GitHub project `Forsaken Bastion's Fall` to `In Progress`, adding the issue to the project if it is missing. Use the `gh project` commands in `.github/TICKET-STANDARD.md` (section "Felder setzen und prüfen") or another available, authorized GitHub Projects v2 tool, then verify with `gh issue view <n> --json projectItems`. Never skip this silently. If no suitable tool is available or the update fails (for example, the token lacks the `project` scope), continue with the implementation and report the exact remaining action, for example: "Set issue #<n> in project `Forsaken Bastion's Fall` to `In Progress`."

## 4. Make the smallest sufficient change

- Change only what the issue asks for. No refactors, renames, reformatting or comment rewrites outside the lines you need to touch. Record unrelated findings under "Bemerkt, nicht geändert" in the PR instead.
- Follow `AGENTS.md`. Read the relevant architecture section of `CLAUDE.md` before a non-trivial gameplay change.
- For any change under `src/`, follow the `safe-vjass-change` skill (`.agents/skills/safe-vjass-change/SKILL.md`) before and after editing.
- For a PR that needs human Warcraft III verification, set the single `DEV_TEST_STAND` constant in `src/GameConfig/GameStart.vj` to `DEV #<issue> T01` for its first requested test. After a test request, increment `T<nn>` before requesting another test only when a new source or map change invalidates that test. Documentation, comments, and other changes that leave the confirmed test valid do not increment it. Commit the current identifier with the source revision before requesting the test. Read the identifier from `GameStart.vj` in that committed revision; never reconstruct it from memory or maintain another identifier.
- Change a `.w3x` only when the issue explicitly requires a direct change of the current development map, and then follow `.agents/skills/safe-w3x-change/SKILL.md` before and after the change. Never change maps in `release/` or a `Working copie` without a separate issue that requires it. Leave `documentation/` alone unless the issue asks for it.

## 5. Run the static checks

- Always run `git diff --check` and `git status --short`, and confirm that only the intended files changed.
- After a change under `src/`, run `bash .agents/skills/safe-vjass-change/scripts/check-vjass-change.sh` and fix every FAIL.
- After a direct map change, run the checks in section 3 of `safe-w3x-change`. Do not commit a map with an unexplained internal change.
- There is no build or test command for the map. Do not invent one. Compiling and playtesting stay pending for a human.

## 6. Commit

- Stage explicit paths only (`git add <path>...`), never `git add -A`, `git add .` or `git commit -a`. For `src/imports.j` with a local prefix, use the staging script from the `safe-vjass-change` skill. Stage a changed map only when the issue requires that change, and never stage backups or temporary maps.
- Review `git diff --cached --stat` and `git diff --cached` before committing.
- Write the commit message in simple German (see `AGENTS.md`, sections "Sprache" and "Commits und Pull Requests"). Subject: the prefix `[#<n>]` and one space at the very start, then a short, specific text that starts with a verb and names the affected behavior or asset, without a trailing period, for example `[#10] Ergänze Ticketnummern in Commit-Betreffzeilen`. Every commit for the issue uses this prefix, including later fix and review commits. Body: what changed and why, then `Refs #<n>`; the prefix does not replace it. Add the attribution trailer your tool is configured to use, if any.

## 7. Push

`git push -u origin <branch>`. Never push to `master`. Force-push (`--force-with-lease`) only your own issue branch, and only when a rebase requires it.

## 8. Open the pull request

`gh pr create --base master --head <branch> --title "[#<n>] <subject>" --body-file <file>`. The title starts with the same `[#<n>]` prefix as the commits. Write the title and body in simple German and keep technical identifiers unchanged. Use this body:

```markdown
Closes #<n>

## Zusammenfassung
- <was sich geändert hat und warum>

## Änderungen
- `<path>`: <was>

## Prüfung
- [x] `git diff --check`: ohne Befund
- [x] `check-vjass-change.sh`: <Ergebnis oder "nicht nötig: keine Änderung unter src/">
- [ ] Map im World Editor gespeichert (JassHelper + vJASS): offen, braucht einen Menschen
- [ ] Spieltest in Warcraft III: offen, braucht einen Menschen
- [ ] Falls der World-Editor-Build die Entwicklungskarte ändert: getestete Datei in diesen PR übernommen

## Nötige Spieltests in Warcraft III
- [ ] <Fraktion, Held, Fähigkeit und Stufe, KI-Schwierigkeit, Spielmodus, worauf zu achten ist>

## Nötige Änderungen im Object Editor
<genaue Rawcodes und Felder oder "Keine">

## Bemerkt, nicht geändert
<optional>
```

For a PR that changes neither a file under `src/` nor a `.w3x`, replace the three unchecked verification items with "Build und Spieltest: nicht nötig, weder `src/` noch eine `.w3x` geändert". For a direct agent change to a `.w3x`, add the section "Direkte Map-Änderung" from `safe-w3x-change`, and list under "Nötige Spieltests in Warcraft III" the check that the intended map data is still present after saving in the World Editor. Mark the Editor-map item as not applicable when saving did not change the tracked map. Never tick compile or playtest boxes yourself. End the body with your tool's PR attribution line, if configured.

## 9. Review, fix and merge

Do not stop after opening the PR. Continue in the same run:

1. **Review.** Read `.agents/skills/review-pr/SKILL.md` completely and apply it to the new PR. Read the complete record, review and verify the current PR head, apply the Warcraft III merge gate and classify every finding. Review your own PR as strictly as a PR written by someone else. Post the review result on the PR, with every finding and its level.
2. **Fix blocking findings.** If a `BLOCKER`, `ERROR` or `MAJOR` is open and you can fix it without a new human decision about design, balance or scope, fix it on the same branch. Follow steps 4 to 7: smallest change, static checks, commit with the `[#<n>]` prefix and `Refs #<n>`, push. Keep the PR description accurate. Then go back to 9.1 and review the new head as a whole. Do not fix `MINOR` findings unless the user explicitly asks for it.
3. **Stop when a human is needed.** Stop the loop and go to step 10 when:
   - a finding needs a human decision about design, balance or scope; ask the decision as a concrete question;
   - a gate needs a human action you cannot perform, for example missing permissions, an independent approval required by branch protection or a ruleset, or a check that fails for reasons outside this repository;
   - a fix round fixes nothing or the same finding comes back; describe what you tried.
4. **Changes under `src/` or to a `.w3x`.** If the PR changes at least one file under `src/` or a `.w3x`, stop before the merge as soon as the missing human verification is the only open `BLOCKER`, `ERROR` or `MAJOR`. Go to step 10 and name the head SHA to test, the World Editor build (JassHelper and vJASS enabled), for a changed `.w3x` the map data to check after saving, and the exact Warcraft III scenario. After a human reports the result on the PR, continue with `review-pr`, including its step for the World Editor build artifact. Commit and push a changed, verified development map to the same PR before merging. The map must be the exact file the human tested; committing those same bytes alone does not require another playtest. A later gameplay-code change or change to the tested map bytes does require renewed verification.
   Before every manual test request, read `DEV_TEST_STAND` from the committed `src/GameConfig/GameStart.vj` at the PR head (for example with `git show HEAD:src/GameConfig/GameStart.vj`) and get the full SHA with `git rev-parse HEAD`. In the console state `Teststand: <exact identifier>`, `Commit: <SHA>`, and `Im Spiel muss beim Start exakt erscheinen: <exact identifier>`. Copy the same read value into the PR test instructions. Ask the human to report the visible identifier and tested commit; a different or older identifier does not confirm this test stand. Ask them to check that the complete presentation, including the identifier, remains visible for about ten seconds.
5. **Merge.** If the PR changes neither a file under `src/` nor a `.w3x`, no `BLOCKER`, `ERROR` or `MAJOR` is open and every other gate passes, finish the PR as `review-pr` describes in "Finish the review" and "After the merge". That covers the approval or the documented self-review, the merge into `master`, the issue, the project status `Done`, the branch cleanup and the fast-forward of the local `master`.

## 10. Report

Report in simple German:

- the PR URL, the branch and the changed files;
- the checks you ran and their results;
- the project status you set, or the exact remaining action;
- every review round with its findings and levels, and the fixes you pushed;
- the open `MINOR` findings;
- either the merge and cleanup results listed in the report section of `review-pr`, or why you stopped: the open decision as a concrete question, the missing human action, or the head SHA and the exact World Editor and Warcraft III tests still needed.

Run `gh pr merge` only in step 9.5. Never enable auto-merge and never close the issue by hand; the merge closes it through `Closes #<n>`.
