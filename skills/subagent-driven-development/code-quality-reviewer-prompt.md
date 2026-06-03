# Code Quality Reviewer Prompt Template

Use this template when dispatching a consolidated code quality reviewer subagent after the draft PR is open.

**Purpose:** Verify the branch/PR implementation is well-built (clean, tested, maintainable)

This can run while CI and consolidated spec review are in progress. If later spec fixes substantially change the implementation, re-run code quality review for the affected area.

```
Task tool (general-purpose):
  Use template at requesting-code-review/code-reviewer.md

  DESCRIPTION: [summary of complete branch/PR implementation]
  PLAN_OR_REQUIREMENTS: [accepted SPEC and implementation plan]
  BASE_SHA: [base branch or PR base]
  HEAD_SHA: [current commit]
```

**In addition to standard code quality concerns, the reviewer should check:**
- Does each file have one clear responsibility with a well-defined interface?
- Are units decomposed so they can be understood and tested independently?
- Is the implementation following the file structure and boundaries from the plan?
- Did this implementation create new files that are already large, or significantly grow existing files? (Don't flag pre-existing file sizes — focus on what this change contributed.)

**Code reviewer returns:** Strengths, Issues (Critical/Important/Minor), Assessment
