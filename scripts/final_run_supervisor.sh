#!/usr/bin/env bash

# Keep the final benchmark campaign running independently of an interactive
# terminal. final_run.py is resumable, so a non-zero exit simply starts another
# pass after a short delay. The loop ends only when the campaign writes COMPLETE.

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CAMPAIGN_ROOT="$REPO_ROOT/finalRun"
PYTHON_BIN="$REPO_ROOT/venv/bin/python"

cd "$REPO_ROOT" || exit 1
mkdir -p "$CAMPAIGN_ROOT"

if [[ -z "${JAVA_HOME_17:-}" ]]; then
    JAVA_HOME_17="$(/usr/libexec/java_home -v 17)" || exit 1
fi
if [[ -z "${JAVA_HOME_8:-}" ]]; then
    JAVA_HOME_8="$(/usr/libexec/java_home -v 1.8)" || exit 1
fi
export JAVA_HOME_17 JAVA_HOME_8

while [[ ! -f "$CAMPAIGN_ROOT/COMPLETE" ]]; do
    printf '[%s] supervisor: resuming all incomplete jobs\n' "$(date -Iseconds)"
    "$PYTHON_BIN" "$SCRIPT_DIR/final_run.py"
    exit_code=$?

    if [[ -f "$CAMPAIGN_ROOT/COMPLETE" ]]; then
        break
    fi

    printf '[%s] supervisor: campaign exited %s without COMPLETE; retrying in 30s\n' \
        "$(date -Iseconds)" "$exit_code"
    sleep 30
done

printf '[%s] supervisor: campaign COMPLETE\n' "$(date -Iseconds)"

# `launchctl submit` creates a keep-alive job. Remove that exact submitted job
# once the campaign is complete so launchd does not restart this finished loop.
if [[ -n "${XPC_SERVICE_NAME:-}" ]]; then
    launchctl remove com.openai.codex.alloy-benchmark-caffeinate || true
    launchctl remove "$XPC_SERVICE_NAME" || true
fi
