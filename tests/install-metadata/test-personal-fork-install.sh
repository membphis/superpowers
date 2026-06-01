#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

FORK_URL="https://github.com/membphis/superpowers"
FORK_GIT_SPEC="superpowers@git+https://github.com/membphis/superpowers.git"
RAW_DEV_INSTALL="https://raw.githubusercontent.com/membphis/superpowers/refs/heads/dev/.opencode/INSTALL.md"
MARKETPLACE_NAME="membphis-superpowers"
AUTHOR_NAME="YuanSheng Wang"
AUTHOR_EMAIL="membphis@gmail.com"

FAILURES=0

pass() {
  echo "  [PASS] $1"
}

fail() {
  echo "  [FAIL] $1"
  FAILURES=$((FAILURES + 1))
}

assert_contains() {
  local file="$1"
  local needle="$2"
  local description="$3"

  if grep -Fq -- "$needle" "$REPO_ROOT/$file"; then
    pass "$description"
  else
    fail "$description"
    echo "    expected $file to contain: $needle"
  fi
}

assert_not_contains() {
  local file="$1"
  local needle="$2"
  local description="$3"

  if grep -Fq -- "$needle" "$REPO_ROOT/$file"; then
    fail "$description"
    echo "    did not expect $file to contain: $needle"
  else
    pass "$description"
  fi
}

json_value() {
  local file="$1"
  local expression="$2"

  node - "$REPO_ROOT/$file" "$expression" <<'NODE'
const fs = require('fs');
const [file, expression] = process.argv.slice(2);
const data = JSON.parse(fs.readFileSync(file, 'utf8'));
const value = Function('data', `return ${expression}`)(data);
process.stdout.write(value == null ? '' : String(value));
NODE
}

assert_json_equals() {
  local file="$1"
  local expression="$2"
  local expected="$3"
  local description="$4"
  local actual

  if [[ ! -f "$REPO_ROOT/$file" ]]; then
    fail "$description"
    echo "    missing JSON file: $file"
    return
  fi

  actual="$(json_value "$file" "$expression")"
  if [[ "$actual" == "$expected" ]]; then
    pass "$description"
  else
    fail "$description"
    echo "    expected: $expected"
    echo "    actual:   $actual"
  fi
}

echo "=== Test: Personal fork install metadata ==="

assert_contains "README.md" "$FORK_URL" "README points at membphis fork"
assert_contains "README.md" "$RAW_DEV_INSTALL" "README points OpenCode at dev install guide"
assert_contains "README.md" "/plugin marketplace add membphis/superpowers" "README documents Claude marketplace install"
assert_contains "README.md" "codex plugin marketplace add https://github.com/membphis/superpowers" "README documents Codex marketplace install"

assert_contains ".opencode/INSTALL.md" "$FORK_GIT_SPEC" "OpenCode install uses membphis git spec"
assert_contains ".opencode/INSTALL.md" "${FORK_GIT_SPEC}#dev" "OpenCode docs show explicit dev pin"
assert_not_contains ".opencode/INSTALL.md" "github.com/obra/superpowers" "OpenCode install no longer points at obra"

assert_contains "docs/README.opencode.md" "$FORK_GIT_SPEC" "OpenCode detailed docs use membphis git spec"
assert_contains "docs/README.opencode.md" "${FORK_GIT_SPEC}#dev" "OpenCode detailed docs show explicit dev pin"
assert_not_contains "docs/README.opencode.md" "github.com/obra/superpowers" "OpenCode detailed docs no longer point at obra"

assert_json_equals ".codex-plugin/plugin.json" "data.author.name" "$AUTHOR_NAME" "Codex manifest author name"
assert_json_equals ".codex-plugin/plugin.json" "data.author.email" "$AUTHOR_EMAIL" "Codex manifest author email"
assert_json_equals ".codex-plugin/plugin.json" "data.author.url" "https://github.com/membphis" "Codex manifest author URL"
assert_json_equals ".codex-plugin/plugin.json" "data.homepage" "$FORK_URL" "Codex manifest homepage"
assert_json_equals ".codex-plugin/plugin.json" "data.repository" "$FORK_URL" "Codex manifest repository"
assert_json_equals ".codex-plugin/plugin.json" "data.interface.developerName" "$AUTHOR_NAME" "Codex interface developer name"
assert_json_equals ".codex-plugin/plugin.json" "data.interface.websiteURL" "$FORK_URL" "Codex interface website"

assert_json_equals ".agents/plugins/marketplace.json" "data.name" "$MARKETPLACE_NAME" "Codex marketplace name"
assert_json_equals ".agents/plugins/marketplace.json" "data.plugins[0].name" "superpowers" "Codex marketplace plugin name"
assert_json_equals ".agents/plugins/marketplace.json" "data.plugins[0].source.path" "./" "Codex marketplace installs repo root"

assert_json_equals ".claude-plugin/plugin.json" "data.author.name" "$AUTHOR_NAME" "Claude manifest author name"
assert_json_equals ".claude-plugin/plugin.json" "data.author.email" "$AUTHOR_EMAIL" "Claude manifest author email"
assert_json_equals ".claude-plugin/plugin.json" "data.homepage" "$FORK_URL" "Claude manifest homepage"
assert_json_equals ".claude-plugin/plugin.json" "data.repository" "$FORK_URL" "Claude manifest repository"

assert_json_equals ".claude-plugin/marketplace.json" "data.name" "$MARKETPLACE_NAME" "Claude marketplace name"
assert_json_equals ".claude-plugin/marketplace.json" "data.owner.name" "$AUTHOR_NAME" "Claude marketplace owner"
assert_json_equals ".claude-plugin/marketplace.json" "data.plugins[0].source" "./" "Claude marketplace installs repo root"

if [[ $FAILURES -gt 0 ]]; then
  echo ""
  echo "FAIL: $FAILURES assertion(s) failed"
  exit 1
fi

echo ""
echo "PASS"
