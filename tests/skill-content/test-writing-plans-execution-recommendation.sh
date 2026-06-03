#!/usr/bin/env bash
# Verifies writing-plans recommends an execution path after persisting a plan.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SKILL="$ROOT/skills/writing-plans/SKILL.md"

fail() {
    echo "[FAIL] $*" >&2
    exit 1
}

assert_contains() {
    local text="$1"
    grep -Fq -- "$text" "$SKILL" || fail "writing-plans skill does not contain: $text"
}

assert_contains "Before asking the user to choose, state your recommended execution path and a brief plan-specific reason."
assert_contains "Base the recommendation on task independence, task count, coupling, file count, review/CI value, subagent availability, and need for continuous context."
assert_contains "Recommend Subagent-Driven for multiple independent or parallelizable tasks, multi-file work, high review value, or work that benefits from early draft PR/CI."
assert_contains "Recommend Inline Execution for tightly coupled, short, sequential, context-heavy work, missing subagent support, or explicit user preference."
assert_contains "The recommendation reason must name the decisive signals, not just repeat the selected option."
assert_contains "When recommending Subagent-Driven, mention why task independence, parallelizability, review/CI value, or fresh context outweighs coordination overhead."
assert_contains "When recommending Inline Execution, mention why coupling, short sequential scope, continuous-context needs, missing subagent support, or user preference outweighs subagent benefits."
assert_contains "Do not treat missing any single Subagent-Driven signal as an automatic Inline Execution recommendation."
assert_contains "My recommendation: <Subagent-Driven or Inline Execution>, because <plan-specific reason naming the decisive signals>."
assert_contains "Always present the execution recommendation as a 1/2 numbered choice, not a free-form question."
assert_contains "1. Execute with the recommended path: <recommended option>"
assert_contains "2. Execute with the other path: <other option>"
assert_contains "Ask the user to reply with 1 or 2."

echo "[PASS] Writing plans gives a recommended execution path"
