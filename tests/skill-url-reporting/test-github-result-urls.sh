#!/usr/bin/env bash
# Verify GitHub issue/PR result reporting instructions keep terminal output clickable.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

FAILURES=0

assert_contains() {
    local file="$1"
    local pattern="$2"
    local description="$3"

    if grep -Eq "$pattern" "$ROOT_DIR/$file"; then
        echo "  [PASS] $description"
    else
        echo "  [FAIL] $description"
        echo "         Missing pattern: $pattern"
        echo "         In file: $file"
        FAILURES=$((FAILURES + 1))
    fi
}

assert_not_contains() {
    local file="$1"
    local pattern="$2"
    local description="$3"

    if grep -Eq "$pattern" "$ROOT_DIR/$file"; then
        echo "  [FAIL] $description"
        echo "         Unexpected pattern: $pattern"
        echo "         In file: $file"
        FAILURES=$((FAILURES + 1))
    else
        echo "  [PASS] $description"
    fi
}

echo "=== GitHub Result URL Reporting Skill Tests ==="

assert_contains \
    "skills/brainstorming/SKILL.md" \
    "result summar(y|ies).*full GitHub issue URL|full GitHub issue URL.*result summar(y|ies)" \
    "brainstorming final summaries require full issue URLs"

assert_contains \
    "skills/brainstorming/SKILL.md" \
    "short .#123. reference.*intermediate|intermediate.*short .#123. reference" \
    "brainstorming keeps short issue references for intermediate progress"

assert_contains \
    "skills/brainstorming/SKILL.md" \
    "sub-project issue.*full GitHub issue URL|full GitHub issue URL.*sub-project issue" \
    "brainstorming decomposition reports sub-project issue URLs"

assert_contains \
    "skills/writing-plans/SKILL.md" \
    "Plan complete.*full GitHub issue URL|full GitHub issue URL.*Plan complete" \
    "writing-plans handoff requires full issue URL"

assert_contains \
    "skills/finishing-a-development-branch/SKILL.md" \
    "full GitHub PR URL" \
    "finishing reports full PR URLs"

assert_contains \
    "skills/subagent-driven-development/SKILL.md" \
    "draft PR.*full GitHub PR URL|full GitHub PR URL.*draft PR" \
    "subagent-driven-development records draft PR URLs"

assert_contains \
    "skills/finishing-a-development-branch/SKILL.md" \
    "local quality gate.*mark.*ready|mark.*ready.*local quality gate" \
    "finishing marks PR ready after local quality gate"

assert_contains \
    "skills/finishing-a-development-branch/SKILL.md" \
    "Do not wait for remote CI.*ready|ready.*Do not wait for remote CI" \
    "finishing does not wait for remote CI before ready"

assert_contains \
    "skills/subagent-driven-development/SKILL.md" \
    "local quality gate.*mark.*ready|mark.*ready.*local quality gate" \
    "subagent-driven-development uses local quality gate before ready"

assert_not_contains \
    "skills/finishing-a-development-branch/SKILL.md" \
    "Draft PR CI is green|Consolidated spec reviewer approved|Code quality reviewer approved" \
    "finishing does not require remote CI or reviewer approvals before ready"

assert_not_contains \
    "skills/subagent-driven-development/SKILL.md" \
    "CI green\\?|Mark PR ready before CI is green|fix CI failures until green|Watch CI and fix CI failures until green" \
    "subagent-driven-development no longer gates ready on CI green"

assert_not_contains \
    "skills/writing-plans/SKILL.md" \
    "fix findings and CI failures before marking ready" \
    "writing-plans no longer teaches CI-failure gate before ready"

if [ "$FAILURES" -gt 0 ]; then
    echo ""
    echo "FAILED: $FAILURES assertion(s) failed."
    exit 1
fi

echo ""
echo "All GitHub result URL reporting checks passed."
