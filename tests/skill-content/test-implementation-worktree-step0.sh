#!/usr/bin/env bash
# Verifies implementation-entry skills require worktree isolation before plan execution.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

fail() {
    echo "[FAIL] $*" >&2
    exit 1
}

line_of() {
    local file="$1"
    local text="$2"
    awk -v text="$text" 'index($0, text) { print NR; exit }' "$file"
}

assert_contains() {
    local file="$1"
    local text="$2"
    grep -Fq -- "$text" "$file" || fail "$file does not contain: $text"
}

assert_order() {
    local file="$1"
    local before="$2"
    local after="$3"
    local before_line
    local after_line

    before_line="$(line_of "$file" "$before")"
    after_line="$(line_of "$file" "$after")"

    [ -n "$before_line" ] || fail "$file does not contain: $before"
    [ -n "$after_line" ] || fail "$file does not contain: $after"
    [ "$before_line" -lt "$after_line" ] || fail "$file has '$before' after '$after'"
}

executing="$ROOT/skills/executing-plans/SKILL.md"
subagent="$ROOT/skills/subagent-driven-development/SKILL.md"

assert_contains "$executing" "### Step 0: Ensure Isolated Workspace"
assert_contains "$executing" "**REQUIRED SUB-SKILL:** Use superpowers:using-git-worktrees"
assert_contains "$executing" "Do not read or execute the plan"
assert_order "$executing" "### Step 0: Ensure Isolated Workspace" "### Step 1: Load and Review Plan"
assert_order "$executing" "**REQUIRED SUB-SKILL:** Use superpowers:using-git-worktrees" "### Step 1: Load and Review Plan"

assert_contains "$subagent" "Use superpowers:using-git-worktrees"
assert_contains "$subagent" "ensure isolated workspace"
assert_contains "$subagent" "[Use superpowers:using-git-worktrees before reading the plan]"
assert_contains "$subagent" "- Skip using-git-worktrees before reading or executing the plan"
assert_order "$subagent" "Use superpowers:using-git-worktrees" "\"Read plan, extract all tasks"

echo "[PASS] Implementation-entry skills require worktree isolation first"
