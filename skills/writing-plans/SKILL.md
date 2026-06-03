---
name: writing-plans
description: Use when you have a spec or requirements for a multi-step task, before touching code
---

# Writing Plans

## Overview

Write comprehensive implementation plans assuming the engineer has zero context for our codebase and questionable taste. Document everything they need to know: which files to touch for each task, code, testing, docs they might need to check, and how to verify it. Give them the whole plan as bite-sized tasks. DRY. YAGNI. Verification-first. Frequent commits.

Assume they are a skilled developer, but know almost nothing about our toolset or problem domain. Assume they don't know good test design very well.

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

**Context:** If working in an isolated worktree, it should have been created via the `superpowers:using-git-worktrees` skill at execution time.

**Default plan location:** `docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md`
- (User preferences for plan destination override this default)
- If invoked from a GitHub issue SPEC that the user chose to proceed from, comment the plan on that issue instead of writing a local plan file, unless the user asks for local Markdown.

## Plan Persistence Destination

Before writing the plan, identify where it should be persisted:

- If the user came from an issue-backed brainstorming flow and chose "Write implementation plan", write the complete plan and post it as a comment on the issue.
- If the user provided a local SPEC file or asked for local Markdown, write the plan to `docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md`.
- If the destination is unclear, ask whether to comment the plan on the issue or write local Markdown.

For issue comments:

1. Keep the issue body as the SPEC; do not overwrite it with the plan.
2. Show the target issue and ask for confirmation before posting the plan comment.
3. Include the complete implementation plan in one comment when possible.
4. If the GitHub write fails, explain the failure and ask whether to retry, write local Markdown, or stop.
5. Do not claim the plan was posted unless the issue comment write succeeded.
6. In result summaries and handoffs, identify the target with its full GitHub issue URL. Short `#123` references are fine for intermediate progress, but not for the final persisted-plan summary.

## Scope Check

If the spec covers multiple independent subsystems, it should have been broken into sub-project specs during brainstorming. If it wasn't, suggest breaking this into separate plans — one per subsystem. Each plan should produce working, testable software on its own.

## File Structure

Before defining tasks, map out which files will be created or modified and what each one is responsible for. This is where decomposition decisions get locked in.

- Design units with clear boundaries and well-defined interfaces. Each file should have one clear responsibility.
- You reason best about code you can hold in context at once, and your edits are more reliable when files are focused. Prefer smaller, focused files over large ones that do too much.
- Files that change together should live together. Split by responsibility, not by technical layer.
- In existing codebases, follow established patterns. If the codebase uses large files, don't unilaterally restructure - but if a file you're modifying has grown unwieldy, including a split in the plan is reasonable.

This structure informs the task decomposition. Each task should produce self-contained changes that make sense independently.

## Bite-Sized Task Granularity

**Each step is one action (2-5 minutes):**
- "Inspect the existing helper this task extends" - step
- "Implement the focused change" - step
- "Add or update the targeted test/check" - step
- "Run the targeted verification command" - step
- "Commit" - step

## Testing Strategy

Plans are verification-first, not TDD-first.

- **Feature work:** Specify the tests, smoke checks, build commands, or manual verification that prove the new behavior works. Do not force test-first steps.
- **Bug fixes:** Start with reproducing the bug. Use `superpowers:test-driven-development` for the fix task so the regression fails before the fix and passes after it.
- **Refactors:** Specify equivalence checks: existing tests, typecheck/build, and any focused smoke check that proves behavior did not change.
- **Docs/config:** Specify the relevant render, validation, install, or command check.

## Plan Document Header

**Every plan MUST start with this header:**

```markdown
# [Feature Name] Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans when executing this plan. For subagent-driven execution, implement tasks with fresh subagents, run cheap local smoke checks, open a draft PR so CI starts, run consolidated reviews while CI runs, fix local findings, then pass the local quality gate and mark the PR ready while remote CI continues. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

---
```

## Task Structure

````markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

- [ ] **Step 1: Inspect existing patterns**

Read `src/existing/module.py` and `tests/existing/test_module.py` to match the local API and test style.

- [ ] **Step 2: Implement the focused change**

```python
def function(input):
    return expected
```

- [ ] **Step 3: Add or update targeted verification**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

- [ ] **Step 4: Run targeted verification**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```
````

## No Placeholders

Every step must contain the actual content an engineer needs. These are **plan failures** — never write them:
- "TBD", "TODO", "implement later", "fill in details"
- "Add appropriate error handling" / "add validation" / "handle edge cases"
- "Write tests for the above" (without actual test code)
- "Similar to Task N" (repeat the code — the engineer may be reading tasks out of order)
- Steps that describe what to do without showing how (code blocks required for code steps)
- References to types, functions, or methods not defined in any task

## Remember
- Exact file paths always
- Complete code in every step — if a step changes code, show the code
- Exact commands with expected output
- DRY, YAGNI, verification-first, frequent commits

## Self-Review

After writing the complete plan, look at the spec with fresh eyes and check the plan against it. This is a checklist you run yourself — not a subagent dispatch.

**1. Spec coverage:** Skim each section/requirement in the spec. Can you point to a task that implements it? List any gaps.

**2. Placeholder scan:** Search your plan for red flags — any of the patterns from the "No Placeholders" section above. Fix them.

**3. Type consistency:** Do the types, method signatures, and property names you used in later tasks match what you defined in earlier tasks? A function called `clearLayers()` in Task 3 but `clearFullLayers()` in Task 7 is a bug.

If you find issues, fix them inline. No need to re-review — just fix and move on. If you find a spec requirement with no task, add the task.

## Execution Handoff

After persisting the plan, offer execution choice.

Before asking the user to choose, state your recommended execution path and a brief plan-specific reason.

Base the recommendation on task independence, task count, coupling, file count, review/CI value, subagent availability, and need for continuous context.

Recommend Subagent-Driven for multiple independent or parallelizable tasks, multi-file work, high review value, or work that benefits from early draft PR/CI.

Recommend Inline Execution for tightly coupled, short, sequential, context-heavy work, missing subagent support, or explicit user preference.

Always present the execution recommendation as a 1/2 numbered choice, not a free-form question.

Ask the user to reply with 1 or 2.

When saying "Plan complete" for an issue-backed plan, `<issue-url-or-path>` must be the full GitHub issue URL, not only `#123`.

The other path is whichever execution path you did not recommend. Use this prompt shape:

> "Plan complete and persisted to `<issue-url-or-path>`.
>
> My recommendation: <Subagent-Driven or Inline Execution>, because <plan-specific reason>.
>
> Choose:
> 1. Execute with the recommended path: <recommended option>
> 2. Execute with the other path: <other option>
>
> If the recommended path is Subagent-Driven, I dispatch fresh implementer subagents, open a draft PR to start CI, run consolidated spec and code quality reviews, then fix local findings, pass the local quality gate, and mark the PR ready while remote CI continues. If the recommended path is Inline Execution, I execute tasks in this session using executing-plans with checkpoints.
>
> Please reply with 1 or 2."

**If Subagent-Driven chosen:**
- **REQUIRED SUB-SKILL:** Use superpowers:subagent-driven-development
- Fresh implementer per task + draft PR/CI + consolidated review flow

**If Inline Execution chosen:**
- **REQUIRED SUB-SKILL:** Use superpowers:executing-plans
- Batch execution with checkpoints for review
