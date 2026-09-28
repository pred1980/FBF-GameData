---
name: implement-ticket
description: Implements one development ticket (a GitHub issue) end-to-end in this repository. Reads the ticket or issue and all its comments, creates a dedicated branch, makes the smallest sufficient change, verifies it with static checks and lists the required manual Warcraft III tests, then commits, pushes and opens a pull request that closes the issue. Use when asked to work on, implement, fix or resolve a ticket or a GitHub issue (for example "implement ticket 12" or "fix issue 12"). Never merges.
---

# Implement a GitHub issue

One issue = one branch = one pull request.

A request to implement an issue authorizes you to create the issue branch, commit to it, push it and open a PR. It never authorizes merging, pushing to `master`, enabling auto-merge or approving the PR; merging is a human decision.

Input: the issue number. If none was given, ask for it.

## 1. Read the issue completely

- `gh issue view <n> --comments`: read the title, body, labels and every comment. Later comments can change the scope.
- Read issues and PRs that the issue links to.
- Check for existing work: `gh pr list --state all --search "<n>"` and `git branch -a --list "*issue-<n>-*"`. If a branch or PR already exists, ask whether to continue it instead of starting over.
- Work out the acceptance criteria. Ask before writing code if the issue is ambiguous, contradicts `AGENTS.md`, or needs a decision that belongs to a human (balance values, design, scope).
- If the issue needs Object Editor changes inside the `.w3x`, say up front that you can only prepare the code and a list of the editor changes.

## 2. Inspect the repository state

```bash
git status --short --branch
git stash list
git fetch origin
```

Never discard, stash, reset, overwrite or commit changes you did not make. If they touch files the issue needs, stop and report them. Otherwise leave them in place: they travel with you to the new branch and stay uncommitted. A typical local change is a machine-specific path prefix in `src/imports.j`; it must never be committed (see the `safe-vjass-change` skill).

## 3. Create the branch

```bash
git switch -c <type>/issue-<n>-<short-slug> origin/master
```

Use `feature`, `fix`, `docs` or `chore` as `<type>`, and 3–5 words from the title as a kebab-case slug, for example `docs/issue-1-vjass-build-workflow`. Never commit on `master`. If the switch fails because of local changes, stop and report.

## 4. Make the smallest sufficient change

- Change only what the issue asks for. No refactors, renames, reformatting or comment rewrites outside the lines you need to touch. Record unrelated findings under "Noticed, not changed" in the PR instead.
- Follow `AGENTS.md`. Read the relevant architecture section of `CLAUDE.md` before a non-trivial gameplay change.
- For any change under `src/`, follow the `safe-vjass-change` skill (`.agents/skills/safe-vjass-change/SKILL.md`) before and after editing.
- Never edit `.w3x` files. Leave `documentation/` alone unless the issue asks for it.

## 5. Run the static checks

- Always run `git diff --check` and `git status --short`, and confirm that only the intended files changed.
- After a change under `src/`, run `bash .agents/skills/safe-vjass-change/scripts/check-vjass-change.sh` and fix every FAIL.
- There is no build or test command for the map. Do not invent one. Compiling and playtesting stay pending for a human.

## 6. Commit

- Stage explicit paths only (`git add <path>...`), never `git add -A`, `git add .` or `git commit -a`. For `src/imports.j` with a local prefix, use the staging script from the `safe-vjass-change` skill.
- Review `git diff --cached --stat` and `git diff --cached` before committing.
- Subject: short and specific, naming the affected behavior or asset (see `AGENTS.md`). Body: what changed and why, then `Refs #<n>`. Add the attribution trailer your tool is configured to use, if any.

## 7. Push

`git push -u origin <branch>`. Never push to `master`. Force-push (`--force-with-lease`) only your own issue branch, and only when a rebase requires it.

## 8. Open the pull request

`gh pr create --base master --head <branch> --title "<subject>" --body-file <file>`, with this body:

```markdown
Closes #<n>

## Summary
- <what changed and why>

## Changes
- `<path>`: <what>

## Verification
- [x] `git diff --check`: clean
- [x] `check-vjass-change.sh`: <result, or "not applicable: no change under src/">
- [ ] Map compiled in the World Editor (JassHelper + vJASS): not done, needs a human
- [ ] Playtested in Warcraft III: not done, needs a human

## Manual Warcraft III tests required
- [ ] <faction, hero, ability and level, AI difficulty, game mode, what to watch for>

## Object Editor changes required
<exact rawcodes and fields, or "None">

## Noticed, not changed
<optional>
```

For a change without gameplay code, replace the two unchecked verification items with "Compile and playtest: not applicable, no gameplay code changed". Never tick compile or playtest boxes yourself. End the body with your tool's PR attribution line, if configured.

## 9. Stop and report

Report the PR URL, the branch, the changed files, the checks you ran and their results, and the manual tests that are still open. Do not run `gh pr merge`, enable auto-merge, approve the PR or close the issue by hand; the merge closes it through `Closes #<n>`.
