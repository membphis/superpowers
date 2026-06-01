---
name: requesting-code-review
description: Use when completing tasks, implementing major features, or before merging to verify work meets requirements
---

# Requesting Code Review

Dispatch a code reviewer subagent to review a completed task, feature, branch, or draft PR. The reviewer gets precisely crafted context for evaluation — never your session's history. This keeps the reviewer focused on the work product, not your thought process, and preserves your own context for continued work.

**Core principle:** Review at the right boundary. Use consolidated review when implementation has been intentionally batched before PR/CI feedback.

## When to Request Review

**Mandatory:**
- After completing major feature
- Before marking a draft PR ready
- Before merge to main

**Optional but valuable:**
- After each task when the task is risky or future tasks depend on its correctness
- When stuck (fresh perspective)
- Before refactoring (baseline check)
- After fixing complex bug

## How to Request

**1. Get git SHAs:**
```bash
BASE_SHA=$(git rev-parse HEAD~1)  # or origin/main
HEAD_SHA=$(git rev-parse HEAD)
```

For consolidated review, use the base branch or PR base as `BASE_SHA` and the current branch head as `HEAD_SHA`.

**2. Dispatch code reviewer subagent:**

Use Task tool with `general-purpose` type, fill template at `code-reviewer.md`

**Placeholders:**
- `{DESCRIPTION}` - Brief summary of what you built
- `{PLAN_OR_REQUIREMENTS}` - What it should do
- `{BASE_SHA}` - Starting commit
- `{HEAD_SHA}` - Ending commit

**3. Act on feedback:**
- Fix Critical issues immediately
- Fix Important issues before proceeding
- Note Minor issues for later
- Push back if reviewer is wrong (with reasoning)

## Example: Task Review

```
[Just completed Task 2: Add verification function]

You: Let me request code review before proceeding.

BASE_SHA=$(git log --oneline | grep "Task 1" | head -1 | awk '{print $1}')
HEAD_SHA=$(git rev-parse HEAD)

[Dispatch code reviewer subagent]
  DESCRIPTION: Added verifyIndex() and repairIndex() with 4 issue types
  PLAN_OR_REQUIREMENTS: Task 2 from docs/superpowers/plans/deployment-plan.md
  BASE_SHA: a7981ec
  HEAD_SHA: 3df7661

[Subagent returns]:
  Strengths: Clean architecture, real tests
  Issues:
    Important: Missing progress indicators
    Minor: Magic number (100) for reporting interval
  Assessment: Ready to proceed

You: [Fix progress indicators]
[Continue to Task 3]
```

## Example: Consolidated Review

```
[All implementer tasks complete, draft PR open, CI running]

BASE_SHA=$(git merge-base HEAD origin/dev)
HEAD_SHA=$(git rev-parse HEAD)

[Dispatch code reviewer subagent]
  DESCRIPTION: Complete draft PR implementation for issue-backed brainstorming specs
  PLAN_OR_REQUIREMENTS: GitHub issue SPEC and implementation plan comment
  BASE_SHA: 7492f86
  HEAD_SHA: d44c346

[Subagent returns]:
  Strengths: Clear flow, well-scoped changes
  Issues:
    Important: Missing failure path for unavailable GitHub CLI
  Assessment: Ready with fixes

You: [Fix issue, rerun affected checks, push to draft PR, re-review affected area]
```

## Integration with Workflows

**Subagent-Driven Development:**
- Default fork flow: run consolidated review after all implementer tasks finish and the draft PR is open
- Review the full branch/PR diff against the SPEC and plan
- Fix blocking findings, rerun affected local checks, push fixes, and re-review affected areas
- Use per-task review only when a task is high-risk or later tasks would compound mistakes

**Executing Plans:**
- Review after each task or at natural checkpoints
- Get feedback, apply, continue

**Ad-Hoc Development:**
- Review before merge
- Review when stuck

## Red Flags

**Never:**
- Skip review because "it's simple"
- Ignore Critical issues
- Proceed with unfixed Important issues
- Argue with valid technical feedback

**If reviewer wrong:**
- Push back with technical reasoning
- Show code/tests that prove it works
- Request clarification

See template at: requesting-code-review/code-reviewer.md
