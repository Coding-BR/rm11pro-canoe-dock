#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

pass() {
  printf 'PASS: %s\n' "$*"
}

need_file() {
  [ -f "$REPO_ROOT/$1" ] || fail "missing file: $1"
  pass "file exists: $1"
}

need_dir() {
  [ -d "$REPO_ROOT/$1" ] || fail "missing directory: $1"
  pass "directory exists: $1"
}

contains_literal() {
  local file="$1"
  local text="$2"
  grep -Fq "$text" "$REPO_ROOT/$file" || fail "missing expected text in $file: $text"
  pass "$file contains expected text"
}

reject_workflow_pattern() {
  local pattern="$1"
  local label="$2"
  shift 2
  local paths=("$@")
  if [ "${#paths[@]}" -eq 0 ]; then
    paths=("$REPO_ROOT/.github/workflows")
  fi
  if grep -R -n -E "$pattern" "${paths[@]}" >/tmp/rm11-route1-workflow-hit.txt 2>/dev/null; then
    sed -n '1,40p' /tmp/rm11-route1-workflow-hit.txt >&2
    fail "forbidden workflow pattern found: $label"
  fi
  pass "workflow pattern absent: $label"
}

cd "$REPO_ROOT"

for dir in \
  .github/workflows \
  anykernel3 \
  apks \
  container \
  docs/ci \
  docs/orangefox-port \
  modules \
  recovery/device/zte/sm88XX \
  recovery/manifests \
  recovery/patches \
  recovery/prebuilts \
  recovery/archive-dead-ends \
  scripts/ci \
  scripts/local-build \
  scripts/recovery
do
  need_dir "$dir"
done

for file in \
  .github/workflows/recovery-verify.yml \
  .github/workflows/orangefox-build-release.yml \
  .github/workflows/anykernel3-verify.yml \
  .github/workflows/apk-verify.yml \
  .github/workflows/module-verify.yml \
  docs/ci/repo-layout.md \
  docs/ci/route1-safe-public-ci.md \
  docs/orangefox-port/17-local-orangefox-build-lane.md \
  docs/orangefox-port/d2n-recovery-baseline-2026-06-15.md \
  recovery/README.md \
  recovery/device/zte/sm88XX/BoardConfig.mk \
  recovery/manifests/d2n-baseline.sha256 \
  scripts/ci/verify-recovery-route1.sh \
  scripts/local-build/build-orangefox-nx809j-local.sh \
  scripts/local-build/env-orangefox-nx809j.example \
  scripts/local-build/README.md \
  scripts/recovery/verify-d2n-preflash.sh
do
  need_file "$file"
done

contains_literal docs/orangefox-port/d2n-recovery-baseline-2026-06-15.md 'a9c70ce885b025fc4b1618798b99bdc05b45239fa76c880415198ab26d9a5fd0'
contains_literal docs/orangefox-port/d2n-recovery-baseline-2026-06-15.md '5394ee6e45417262f631c9783dc2904b5baeb2cbe9108561053b711c1ef62cab'
contains_literal recovery/manifests/d2n-baseline.sha256 'a9c70ce885b025fc4b1618798b99bdc05b45239fa76c880415198ab26d9a5fd0'
contains_literal recovery/manifests/d2n-baseline.sha256 '5394ee6e45417262f631c9783dc2904b5baeb2cbe9108561053b711c1ef62cab'
contains_literal scripts/recovery/verify-d2n-preflash.sh 'EXPECTED_SHA256="${EXPECTED_SHA256:-a9c70ce885b025fc4b1618798b99bdc05b45239fa76c880415198ab26d9a5fd0}"'

for script in scripts/ci/verify-recovery-route1.sh scripts/local-build/build-orangefox-nx809j-local.sh scripts/recovery/verify-d2n-preflash.sh; do
  [ -x "$script" ] || fail "script is not executable: $script"
  pass "script is executable: $script"
done

reject_workflow_pattern 'self-hosted' 'self-hosted runner'
reject_workflow_pattern '/home/[A-Za-z0-9._-]+' 'private maintainer path'
reject_workflow_pattern '(^|[[:space:]])fastboot([[:space:]]|$)' 'fastboot'
reject_workflow_pattern '(^|[[:space:]])adb([[:space:]]|$)' 'adb'
reject_workflow_pattern '(^|[[:space:]])dd[[:space:]]+if=' 'dd partition reads/writes'
reject_workflow_pattern 'secrets\.' 'GitHub secrets'
reject_workflow_pattern '(^|[[:space:]])repo[[:space:]]+sync([[:space:]]|$)' 'repo sync' \
  "$REPO_ROOT/.github/workflows/recovery-verify.yml" \
  "$REPO_ROOT/.github/workflows/anykernel3-verify.yml" \
  "$REPO_ROOT/.github/workflows/apk-verify.yml" \
  "$REPO_ROOT/.github/workflows/module-verify.yml"

mapfile -t bash_scripts < <(
  {
    printf '%s\n' scripts/ci/verify-recovery-route1.sh
    printf '%s\n' scripts/local-build/build-orangefox-nx809j-local.sh
    printf '%s\n' scripts/local-build/build-orangefox-test-candidate-legacy.sh
    find scripts/recovery -maxdepth 1 -type f -name 'verify-*.sh' | sort
  } | awk '!seen[$0]++'
)

for script in "${bash_scripts[@]}"; do
  bash -n "$script"
  pass "bash syntax ok: $script"
done

if command -v shellcheck >/dev/null 2>&1; then
  shellcheck -S warning "${bash_scripts[@]}"
  pass "shellcheck passed"
else
  printf 'WARN: shellcheck unavailable; bash -n checks completed.\n'
fi

printf '\nRESULT: PASS. Route 1 recovery verifier completed without device writes.\n'
