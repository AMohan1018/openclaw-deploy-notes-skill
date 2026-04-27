#!/usr/bin/env bash
set -u

OPENCLAW_BIN="${OPENCLAW_BIN:-$HOME/.openclaw/bin/openclaw}"

section() {
  printf '\n## %s\n' "$1"
}

run_check() {
  local label="$1"
  shift
  section "$label"
  printf '$ %s\n' "$*"
  "$@"
  local status=$?
  if [ "$status" -ne 0 ]; then
    printf 'exit_code=%s\n' "$status"
  fi
  return 0
}

section "OpenClaw first read-only check"
printf 'openclaw_bin=%s\n' "$OPENCLAW_BIN"

if [ ! -x "$OPENCLAW_BIN" ]; then
  printf 'ERROR: OpenClaw binary not executable at %s\n' "$OPENCLAW_BIN"
  exit 1
fi

run_check "version" "$OPENCLAW_BIN" --version
run_check "gateway_status" "$OPENCLAW_BIN" gateway status
run_check "doctor" "$OPENCLAW_BIN" doctor
run_check "memory_status" "$OPENCLAW_BIN" memory status --deep
run_check "web_search_provider" "$OPENCLAW_BIN" config get tools.web.search.provider
