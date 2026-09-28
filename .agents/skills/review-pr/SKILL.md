---
name: review-pr
description: Review a GitHub pull request against its linked issue in Forsaken Bastion's Fall, leave actionable feedback when blocked, and merge into master only after code, CI, and required human Warcraft III verification pass, then set the project status and safely clean up the merged branch. Use when asked to review or merge a PR by number.
---

# Review and merge a pull request

Input: a PR number. If none was given, ask for it. Invoking this skill authorizes review feedback and, only after every gate below passes, approval, a normal merge into `master` and the cleanup after the merge described below. Never enable auto-merge or force-push.

`implement-ticket` runs this skill in its step 9 right after it opens a PR. In that flow, `implement-ticket` fixes blocking findings on the PR branch and then runs this skill again on the new head. A standalone run of this skill gives feedback and does not change the PR's files unless the user explicitly asks for a fix.

Write review comments, feedback and the final report in simple German (see `AGENTS.md`, "Sprache"). Keep technical identifiers unchanged.

## Read the complete record

- Read `AGENTS.md` and `CLAUDE.md`. Inspect the PR title, body, base/head, draft and mergeability state, every commit, the complete changed-file list and diff, all comments, reviews and review threads (including unresolved threads), and available CI/status checks. Use `gh pr view`, `gh pr diff`, `gh api` or equivalent; paginate API results rather than relying on a truncated view.
- Identify the linked GitHub issue from explicit PR links or closing references. Read its full title, body and every comment, including later scope decisions. If the linkage is absent or ambiguous, ask which issue governs the PR before deciding to merge. Do not derive requirements solely from the branch name or invent acceptance criteria.
- Compare the PR with the issue's actual scope and acceptance criteria. Flag unrelated changes. Inspect affected code and important callers/consumers, not just the diff.

## Review and verify the PR head

- Preserve unrelated local changes. Review and run checks against the PR's current head. When local changes would contaminate results, use a temporary detached worktree outside the repository, for example `git worktree add --detach "<tmp-dir>/pr-<n>" <head-sha>`, and record the path of every worktree you create. A detached worktree creates no local branch. Do not modify gameplay code as part of review unless explicitly asked to fix the PR.
- For changes under `src/`, read and apply `.agents/skills/safe-vjass-change/SKILL.md`. Check relevant rawcodes and order strings across `src/`, hero ability/AI coupling, shared-library consumers, new `.vj` entries in `src/imports.j`, encoding and line endings, and any `.w3x` or Object Editor implications. A changed binary map is a `BLOCKER` under `AGENTS.md`.
- Run applicable static checks against the PR changes, including `git diff --check` for the PR diff. For vJASS, use the safe-vJASS script in a suitable PR-head checkout and inspect its findings; the script compares its working tree to `HEAD`, so it cannot by itself validate an already committed PR diff. Inspect committed changes separately.
- Check current GitHub CI/status results, required approvals, branch protection and repository rulesets (`gh api repos/<owner>/<repo>/branches/master/protection`, `gh api repos/<owner>/<repo>/rules/branches/master` and `reviewDecision` in `gh pr view`). Failed, pending, missing required or stale checks block merging. Confirm the PR is open, targets `master`, is not a draft, and is cleanly mergeable. Unresolved review threads and outstanding change requests block merging until addressed.
- Never report an agent static check as a World Editor/JassHelper compile or Warcraft III runtime test.

## Warcraft III merge gate

- The PR's changed-file list decides whether this gate applies. If the PR changes at least one file under `src/`, human Warcraft III verification is required before merging. If it changes no file under `src/`, there is no Warcraft III test gate. A changed `.w3x` is a `BLOCKER` in any case (see above).
- For a PR with changes under `src/`, require an explicit human report on the PR or linked issue that the **current PR head** saved successfully in the World Editor with JassHelper and vJASS enabled, and that the required Warcraft III scenario was playtested successfully. Check that the report covers the affected hero, system or mode and any relevant AI difficulty or Object Editor work. The tested head is the commit the report names; if it names none, take the PR head at the time of the report. If later commits change files under `src/` (`git diff --name-only <tested-sha> <head-sha> -- src`), require renewed verification for the new head. Later commits that change only files outside `src/` keep the confirmed result valid.
- If either human result is missing or unsuccessful, leave the PR open. State the exact compile step and playtest scenario still needed. Passing static checks or CI does not waive this gate.

## Classify every finding

Assign every finding exactly one of these four severity levels. Use no other levels, labels or traffic lights.

| Level | Meaning | Examples | Merge |
|---|---|---|---|
| `BLOCKER` | Merging is unsafe or not possible at all. | changed `.w3x`; failed, pending or missing required checks; merge conflict; missing human Warcraft III verification for a PR with changes under `src/`; missing approval that branch protection or a ruleset requires | blocks |
| `ERROR` | A confirmed defect, or an acceptance criterion of the linked issue is not met. | wrong number or fact; broken reference or path; required file or section missing | blocks |
| `MAJOR` | A substantial problem with correctness, architecture, scope or maintainability that must be fixed before merging. | unrelated changes; rules that contradict each other; a design that will clearly cause follow-up defects | blocks |
| `MINOR` | A small improvement, style question, wording issue or other non-critical observation. | clearer wording; formatting; optional cleanup | does not block |

- If a finding fits more than one level, use the highest level that applies. Give each finding its evidence and what would resolve it.
- Every failed gate from the sections above is a `BLOCKER`. Missing human verification alone is a `BLOCKER` for the merge, not a code defect; say so.
- `BLOCKER`, `ERROR` and `MAJOR` must be fixed before merging.
- Document `MINOR` findings in the review; they do not block the merge. Do not fix them in the current PR unless the user explicitly asks for it. Do not create follow-up issues for them; a human decides whether a later ticket is needed.
- Put `MINOR` findings in the review body or PR comment, not in separate review threads, so the thread rule above does not make them block the merge.
- On a re-review, check that every earlier `BLOCKER`, `ERROR` and `MAJOR` is fixed, then review the new head as a whole. Newly found `BLOCKER`, `ERROR` or `MAJOR` block the merge again, also in parts that did not change. Do not raise a documented `MINOR` to a higher level unless new evidence shows a larger impact; name that evidence.
- Write findings in simple German and keep the level names unchanged. Start each finding with its level, for example: `ERROR: K4 nennt 21 statt 25 Units.`

## Finish the review

- If any `BLOCKER`, `ERROR` or `MAJOR` is open, do not merge. Leave precise feedback on the PR that lists every finding with its level and states what would clear it, and request changes when code or scope must change. For missing human verification alone, leave a clear comment rather than claiming a code defect.
- If every gate passes and only `MINOR` findings or no findings remain, approve when GitHub permits and approval is appropriate. List the open `MINOR` findings in the review so they stay visible.
- If GitHub refuses an approval or a change request only because the reviewer is the PR author, post the complete review result as a PR comment instead. A refused self-approval alone does not block the merge. If branch protection, a ruleset or `reviewDecision` `REVIEW_REQUIRED` requires an approving review, an approval by another account is a real gate: it stays a `BLOCKER` until it exists, and you must never bypass it.
- Recheck the PR head, checks, reviews, mergeability and human-test evidence immediately before merging. Merge into `master` with an ordinary supported merge method; never bypass failed checks, required approvals or branch protection, and never use auto-merge. Do not pass `--delete-branch` to `gh pr merge`; clean up branches with the checked steps below.
- Remove every temporary worktree this review created once it is no longer needed, whether or not the PR merged: `git worktree remove <path>`, never with `--force`. If Git refuses because the worktree has changes, leave it and report its path. Never remove a worktree you did not create.

## After the merge

Only after a successful merge. Work through these steps in order and record the result of each one for the report.

1. **Issue:** Confirm the linked issue closed through the PR's closing reference. If it remains open, close it only when the merged PR fully satisfies it and the linkage is unambiguous; otherwise report its state for a human decision.
2. **Project status:** Set the linked issue's Status in the GitHub project `Forsaken Bastion's Fall` to `Done`. Use the `gh project` commands in `.github/TICKET-STANDARD.md` (section "Felder setzen und prüfen") or another available, authorized GitHub Projects v2 tool, then verify with `gh issue view <n> --json projectItems`. If a project automation already set `Done`, report that. Never skip this silently: if no suitable tool is available or the update fails, report the exact remaining action, for example "Set issue #<n> in project `Forsaken Bastion's Fall` to `Done`."
3. **Branch facts:** Run `gh pr view <pr> --json headRefName,headRefOid,isCrossRepository,mergeCommit`, then `git fetch origin --prune`. Below, `<branch>` is `headRefName` and `<head-sha>` is `headRefOid`.
4. **Remote branch:** Delete it with `git push origin --delete <branch>` only if all of these hold:
   - `<branch>` is not `master` and not the repository's default branch;
   - `isCrossRepository` is false, so the branch belongs to this repository;
   - no other open PR uses `<branch>` as head or base (`gh pr list --state open --head <branch>` and `gh pr list --state open --base <branch>` print nothing);
   - the remote tip still equals `<head-sha>` (`git ls-remote origin refs/heads/<branch>`), so nobody pushed after the merge.

   If the remote branch no longer exists, report that. If any condition fails, keep the branch and report which condition failed.
5. **Temporary worktrees:** Remove any worktree this review created that still exists, as described in "Finish the review".
6. **Local branch:** Check `git branch --list <branch>` and `git worktree list --porcelain`. Delete the local branch only if all of these hold:
   - `<branch>` is not `master`;
   - it is not checked out in another worktree;
   - it has no commits beyond the merged head: `git rev-list <head-sha>..<branch>` prints nothing. If `<head-sha>` is not available locally even after the fetch, keep the branch;
   - if it is checked out in the current worktree, `git status --porcelain --untracked-files=no` prints nothing and a plain `git switch master` succeeds. Never use `--force`, `--discard-changes`, `git stash`, `git reset --hard` or `git checkout -- .` to make the switch possible.

   Delete it with `git branch -d <branch>`. If Git refuses only because the branch is not merged into the current `HEAD` (a squash or rebase merge, or a local `master` that is still behind) and the `rev-list` check printed nothing, `git branch -D <branch>` is allowed; the commits stay available through the PR. Otherwise keep the branch and report exactly why.
7. **Local `master`:** Update it only by fast-forward. If the current worktree is on `master`, run `git pull --ff-only origin master`. If `master` is not checked out in any worktree, `git fetch origin master:master` fast-forwards it without touching a working tree. If `master` is checked out in another worktree, the update is not a fast-forward, or Git refuses because local changes would be overwritten, leave `master` as it is and report why.

## Report

Report in simple German, with each point listed separately:

- review findings, each with its severity level, checks, human verification evidence, and the feedback or approval given, including whether the approval was formal or documented as a PR comment because GitHub refused a self-approval;
- merged PR (number, merge method, merge commit), or, if the PR stays open, every open `BLOCKER`, `ERROR` and `MAJOR` and the exact manual test still required;
- open `MINOR` findings that were documented but not fixed;
- closed issue and project status (`Done`, or the exact remaining action);
- deleted remote branch;
- deleted local branch;
- removed temporary worktrees;
- update of the local `master`;
- every cleanup step that was intentionally skipped, with the reason.
