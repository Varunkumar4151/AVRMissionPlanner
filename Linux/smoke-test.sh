#!/usr/bin/env bash
# Basic window/startup check only; does not validate vehicle communications.
set -euo pipefail
package_dir="$(realpath "${1:?Usage: smoke-test.sh PACKAGE_DIRECTORY}")"
evidence_dir="$(realpath "${2:?Supply an existing evidence directory}")"
bash "$package_dir/run-avr.sh" >"$evidence_dir/startup.log" 2>&1 &
app_pid=$!
cleanup() {
    kill "$app_pid" 2>/dev/null || true
    wait "$app_pid" 2>/dev/null || true
}
trap cleanup EXIT
for ((attempt=0; attempt<45; attempt++)); do
    if ! kill -0 "$app_pid" 2>/dev/null; then
        cat "$evidence_dir/startup.log"
        echo 'Application exited during startup.' >&2
        exit 1
    fi
    sleep 1
done
xwininfo -root -tree >"$evidence_dir/windows.txt"
import -window root "$evidence_dir/startup.png"
if grep -Eiq 'FATAL UNHANDLED EXCEPTION|Unhandled Exception:' "$evidence_dir/startup.log"; then
    cat "$evidence_dir/startup.log"
    exit 1
fi
if ! xdotool search --onlyvisible --name 'Mission Planner' >"$evidence_dir/window-ids.txt"; then
    echo 'No visible Mission Planner window found.' >&2
    exit 1
fi
echo 'Process survived 45 seconds and a Mission Planner window is visible.'
echo 'Review startup.png and startup.log; this is not a flight-readiness test.'
