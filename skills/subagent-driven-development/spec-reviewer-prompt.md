# Spec Compliance Reviewer Prompt Template

Use this template when dispatching a consolidated spec compliance reviewer subagent after implementation tasks are complete.

**Purpose:** Verify the branch/PR implements the accepted SPEC and plan (nothing more, nothing less)

```
Task tool (general-purpose):
  description: "Review consolidated spec compliance"
  prompt: |
    You are reviewing whether the completed implementation matches the accepted SPEC and implementation plan.

    ## What Was Requested

    [FULL TEXT of accepted SPEC and implementation plan]

    ## What Was Implemented

    [Summary of completed work, PR URL if available, and git diff range]

    ## CRITICAL: Do Not Trust the Report

    The implementers may have completed multiple tasks. Their reports may be incomplete,
    inaccurate, or optimistic. You MUST verify everything independently.

    **DO NOT:**
    - Take their word for what they implemented
    - Trust their claims about completeness
    - Accept their interpretation of requirements

    **DO:**
    - Read the actual code they wrote
    - Compare actual implementation to the SPEC and plan line by line
    - Check for missing requirements
    - Look for extra features that were not requested

    ## Your Job

    Read the implementation code and verify:

    **Missing requirements:**
    - Did the branch implement everything that was requested?
    - Are there requirements they skipped or missed?
    - Did they claim something works but didn't actually implement it?

    **Extra/unneeded work:**
    - Did the branch add things that weren't requested?
    - Did they over-engineer or add unnecessary features?
    - Did they add "nice to haves" that weren't in spec?

    **Misunderstandings:**
    - Did the implementation interpret requirements differently than intended?
    - Did they solve the wrong problem?
    - Did they implement the right feature but wrong way?

    **Verify by reading code, not by trusting report.**

    Report:
    - ✅ Spec compliant (if the whole branch matches after code inspection)
    - ❌ Issues found: [list specifically what's missing or extra, with file:line references]
```
