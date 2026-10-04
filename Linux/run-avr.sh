#!/usr/bin/env bash
set -euo pipefail
app_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if ! command -v mono >/dev/null 2>&1; then
    echo 'Mono is required. On Ubuntu: sudo apt install mono-complete libgdiplus fonts-dejavu-core' >&2
    exit 1
fi
if [[ ! -f "$app_dir/MissionPlanner.exe" ]]; then
    echo 'Run this launcher from the extracted AVRMissionPlanner-linux-x86_64 package.' >&2
    exit 1
fi
if [[ -z "${DISPLAY:-}" ]]; then
    echo 'An X11 or XWayland desktop session is required (DISPLAY is unset).' >&2
    exit 1
fi
export LD_LIBRARY_PATH="$app_dir:$app_dir/runtimes/linux-x64/native${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
cd -- "$app_dir"
exec mono MissionPlanner.exe "$@"
