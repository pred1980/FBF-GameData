---
name: review-pr
description: Review a GitHub pull request against its linked issue in Forsaken Bastion's Fall, leave actionable feedback when blocked, and merge into master only after code, CI, and required human Warcraft III verification pass, then set the project status and safely clean up the merged branch. Use when asked to review or merge a PR by number.
---

# Review and merge a pull request

Input: a PR number. If none was given, ask for it. Invoking this skill authorizes review feedback and, only after every gate below passes, approval, a normal merge into `master` and the cleanup after the merge described below. Never enable auto-merge or force-push.

Write review comments, feedback and the final report in simple German (see `AGENTS.md`, "Sprache"). Keep technical identifiers unchanged.

## Read the complete record

- Read `AGENTS.md` and `CLAUDE.md`. Inspect the PR title, body, base/head, draft and mergeability state, every commit, the complete changed-file list and diff, all comments, reviews and review threads (including unresolved threads), and available CI/status checks. Use `gh pr view`, `gh pr diff`, `gh api` or equivalent; paginate API results rather than relying on a truncated view.
- Identify the linked GitHub issue from explicit PR links or closing references. Read its full title, body and every comment, including later scope decisions. If the linkage is absent or ambiguous, ask which issue governs the PR before deciding to merge. Do not derive requirements solely from the branch name or invent acceptance criteria.
- Compare the PR with the issue's actual scope and acceptance criteria. Flag unrelated changes. Inspect affected code and important callers/consumers, not just the diff.

## Review and verify the PR head

- Preserve unrelated local changes. Review and run checks against the PR's current head. When local changes would contaminate results, use a temporary detached worktree outside the repository, for example `git worktree add --detach "<tmp-dir>/pr-<n>" <head-sha>`, and record the path of every worktree you create. A detached worktree creates no local branch. Do not modify gameplay code as part of review unless explicitly asked to fix the PR.
- For changes under `src/`, read and apply `.agents/skills/safe-vjass-change/SKILL.md`. Check relevant rawcodes and order strings across `src/`, hero ability/AI coupling, shared-library consumers, new `.vj` entries in `src/imports.j`, encoding and line endings, and any `.w3x` or Object Editor implications. A changed binary map is a blocker under `AGENTS.md`.
- Run applicable static checks against the PR changes, including `git diff --check` for the PR diff. For vJASS, use the safe-vJASS script in a suitable PR-head checkout and inspect its findings; the script compares its working tree to `HEAD`, so it cannot by itself validate an already committed PR diff. Inspect committed changes separately.
- Check current GitHub CI/status results, required approvals and branch protection. Failed, pending, missing required or stale checks block merging. Confirm the PR is open, targets `master`, is not a draft, and is cleanly mergeable. Unresolved review threads and outstanding change requests block merging until addressed.
- Never report an agent static check as a World Editor/JassHelper compile or Warcraft III runtime test.

## Warcraft III merge gate

- Documentation-only and tooling-only changes may merge without a Warcraft III playtest when review confirms they cannot affect map runtime behavior.
- For any gameplay or runtime-affecting change, require an explicit human report on the PR or linked issue that the **current PR head** saved successfully in the World Editor with JassHelper and vJASS enabled, and that the required Warcraft III scenario was playtested successfully. Check that the report covers the affected hero, system or mode and any relevant AI difficulty or Object Editor work. If the head changed afterward, require renewed verification for affected behavior.
- If either human result is missing or unsuccessful, leave the PR open. State the exact compile step and playtest scenario still needed. Passing static checks or CI does not waive this gate.

## Finish the review

- If implementation, scope, verification or merge gates fail, do not merge. Leave precise feedback on the PR, request changes when code or scope must change, and state what would clear each blocker. For missing human verification alone, leave a clear comment rather than claiming a code defect.
- If every gate passes, approve when GitHub permits and approval is appropriate. Recheck the PR head, checks, reviews, mergeability and human-test evidence immediately before merging. Merge into `master` with an ordinary supported merge method; never bypass failed checks, required approvals or branch protection, and never use auto-merge. Do not pass `--delete-branch` to `gh pr merge`; clean up branches with the checked steps below.
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

- review findings, checks, human verification evidence, and the feedback or approval given;
- merged PR (number, merge method, merge commit), or, if the PR stays open, every remaining blocker and the exact manual test still required;
- closed issue and project status (`Done`, or the exact remaining action);
- deleted remote branch;
- deleted local branch;
- removed temporary worktrees;
- update of the local `master`;
- every cleanup step that was intentionally skipped, with the reason.
