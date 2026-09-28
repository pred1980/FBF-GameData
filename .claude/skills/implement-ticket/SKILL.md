---
name: implement-ticket
description: Implements one development ticket (a GitHub issue) end-to-end in this repository. Reads the ticket or issue and all its comments, creates a dedicated branch, makes the smallest sufficient change, verifies it with static checks, commits, pushes and opens a pull request that closes the issue. Then continues with the review-pr flow - reviews the PR, fixes BLOCKER, ERROR and MAJOR findings, re-reviews and merges when no file under src/ changed; with changes under src/ it stops before the merge until a human confirms the World Editor build and Warcraft III playtest. Use when asked to work on, implement, fix or resolve a ticket or a GitHub issue (for example "implement ticket 12" or "fix issue 12").
argument-hint: "[issue-number]"
---

<!-- Claude Code wrapper. The canonical skill is .agents/skills/implement-ticket/SKILL.md,
     which Codex reads directly. Edit that file; keep name and description here identical to it. -->

Read `.agents/skills/implement-ticket/SKILL.md` completely and follow it.

Issue: $ARGUMENTS
