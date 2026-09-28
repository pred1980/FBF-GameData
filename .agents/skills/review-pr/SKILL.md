---
name: review-pr
description: Review a GitHub pull request against its linked issue in Forsaken Bastion's Fall, leave actionable feedback when blocked, and merge into master only after code, CI, and required human Warcraft III verification pass. Use when asked to review or merge a PR by number.
---

# Review and merge a pull request

Input: a PR number. If none was given, ask for it. Invoking this skill authorizes review feedback and, only after every gate below passes, approval and a normal merge into `master`. Never enable auto-merge or force-push.

## Read the complete record

- Read `AGENTS.md` and `CLAUDE.md`. Inspect the PR title, body, base/head, draft and mergeability state, every commit, the complete changed-file list and diff, all comments, reviews and review threads (including unresolved threads), and available CI/status checks. Use `gh pr view`, `gh pr diff`, `gh api` or equivalent; paginate API results rather than relying on a truncated view.
- Identify the linked GitHub issue from explicit PR links or closing references. Read its full title, body and every comment, including later scope decisions. If the linkage is absent or ambiguous, ask which issue governs the PR before deciding to merge. Do not derive requirements solely from the branch name or invent acceptance criteria.
- Compare the PR with the issue's actual scope and acceptance criteria. Flag unrelated changes. Inspect affected code and important callers/consumers, not just the diff.

## Review and verify the PR head

- Preserve unrelated local changes. Review and run checks against the PR's current head, using an isolated checkout or worktree when local changes would contaminate results. Do not modify gameplay code as part of review unless explicitly asked to fix the PR.
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
- If every gate passes, approve when GitHub permits and approval is appropriate. Recheck the PR head, checks, reviews, mergeability and human-test evidence immediately before merging. Merge into `master` with an ordinary supported merge method; never bypass failed checks, required approvals or branch protection, and never use auto-merge.
- Confirm the linked issue closes through the PR's closing reference. If it remains open, close it only when the merged PR fully satisfies it and the linkage is unambiguous; otherwise report its state for a human decision.
- Report the review findings, checks and human verification evidence, feedback or approval, merge result and issue state. If left open, name every remaining blocker and exact manual test required.
