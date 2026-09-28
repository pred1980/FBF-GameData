---
name: implement-ticket
description: Implements one development ticket (a GitHub issue) end-to-end in this repository. Reads the ticket or issue and all its comments, creates a dedicated branch, makes the smallest sufficient change, verifies it with static checks and lists the required manual Warcraft III tests, then commits, pushes and opens a pull request that closes the issue. Use when asked to work on, implement, fix or resolve a ticket or a GitHub issue (for example "implement ticket 12" or "fix issue 12"). Never merges.
argument-hint: "[issue-number]"
---

<!-- Claude Code wrapper. The canonical skill is .agents/skills/implement-ticket/SKILL.md,
     which Codex reads directly. Edit that file; keep name and description here identical to it. -->

Read `.agents/skills/implement-ticket/SKILL.md` completely and follow it.

Issue: $ARGUMENTS
