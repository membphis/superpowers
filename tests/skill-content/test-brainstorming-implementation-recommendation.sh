#!/usr/bin/env bash
# Verifies brainstorming recommends an implementation path instead of only handing
# the choice to the user.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SKILL="$ROOT/skills/brainstorming/SKILL.md"

fail() {
    echo "[FAIL] $*" >&2
    exit 1
}

assert_contains() {
    local text="$1"
    grep -Fq -- "$text" "$SKILL" || fail "brainstorming skill does not contain: $text"
}

assert_contains "Before asking the user to choose, state your recommended implementation path and a brief task-specific reason."
assert_contains "Base the recommendation on task size, risk, file count, ambiguity, expected duration, and PR sensitivity."
assert_contains "Recommend Direct implementation for small, low-risk, clearly scoped changes."
assert_contains "Recommend Write implementation plan for large, high-risk, multi-file, ambiguous, long-running, or PR-sensitive work."
assert_contains "My recommendation: <Direct implementation or Write implementation plan>, because <task-specific reason>."
assert_contains "Always present the recommendation as a 1/2/3 numbered choice, not a free-form question."
assert_contains "1. Proceed with the current SPEC and use the recommended path: <recommended option>"
assert_contains "2. Proceed with the current SPEC and use the other path: <other option>"
assert_contains "3. Request SPEC changes before proceeding"
assert_contains "Ask the user to reply with 1, 2, or 3."
assert_contains "If they choose 1 or 2, treat the current SPEC as accepted for implementation and proceed down that path."

if grep -Fq -- "Approve SPEC" "$SKILL"; then
    fail "brainstorming skill should not imply a separate persisted SPEC approval state"
fi

if grep -Fq -- "treat the SPEC as approved" "$SKILL"; then
    fail "brainstorming skill should not describe numeric choices as approving a persisted SPEC state"
fi

echo "[PASS] Brainstorming gives a recommended implementation path"
