---
name: review-pr
description: Review a GitHub pull request against its linked issue in Forsaken Bastion's Fall, leave actionable feedback when blocked, and merge into master only after code, CI, and required human Warcraft III verification pass. Use when asked to review or merge a PR by number.
argument-hint: "[pr-number]"
---

<!-- Claude Code wrapper. The canonical skill is .agents/skills/review-pr/SKILL.md,
     which Codex reads directly. Edit that file; keep name and description here identical to it. -->

Read `.agents/skills/review-pr/SKILL.md` completely and follow it.

Pull request: $ARGUMENTS
