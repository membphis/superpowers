#!/usr/bin/env bash
# Verifies active workflow skills do not imply a persisted SPEC approval state.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

FILES=(
    "skills/brainstorming/SKILL.md"
    "skills/writing-plans/SKILL.md"
    "skills/subagent-driven-development/spec-reviewer-prompt.md"
    "skills/subagent-driven-development/code-quality-reviewer-prompt.md"
)

for file in "${FILES[@]}"; do
    path="$ROOT/$file"
    if grep -Eiq "approved[[:space:]]+SPEC" "$path"; then
        echo "[FAIL] $file should not imply a separate persisted SPEC approval state" >&2
        exit 1
    fi
done

echo "[PASS] Active workflow skills avoid persisted SPEC approval language"
