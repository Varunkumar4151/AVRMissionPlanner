# AVR Mission Planner — build locally on Linux

Repository: https://github.com/Varunkumar4151/AVRMissionPlanner

Branch: `airview/linux-development`

Base: stable `MissionPlanner1.3.83`, commit
`b78a7495fec69793f2fcc13be4b6a3d9e06b3e4e`.

Linux compatibility changes were backported from ArduPilot/MissionPlanner
commit `5f07a4d6bca1eecf097234da111c31c1985ef387`. The stable communications
project predates that commit's WinUSB changes, so those changes were not
applied. This branch remains a stable-based derivative rather than switching
to upstream master. Existing flight logic remains the stable implementation.

## Status

Local Linux build support is prepared for verification on the developer's
machine. Shell syntax, project XML, patch context and source paths were
checked. This backport has not yet been compiled or run on Linux. A previous
Windows compilation passed; that does not validate this local Linux build.
Automatic cloud builds are disabled on this branch. Android is deferred.

## 1. Install dependencies on Ubuntu 24.04 x86_64

```bash
sudo apt update
sudo apt install -y git curl ca-certificates mono-devel mono-runtime libgdiplus fonts-dejavu-core rsync
```

Install the .NET 10 SDK into your user directory using Microsoft's installer:

```bash
curl -fsSL https://dot.net/v1/dotnet-install.sh -o /tmp/avr-dotnet-install.sh
bash /tmp/avr-dotnet-install.sh --channel 10.0 --install-dir "$HOME/.dotnet"
export DOTNET_ROOT="$HOME/.dotnet"
export PATH="$DOTNET_ROOT:$PATH"
dotnet --version
mono --version
```

Use the same two `export` commands in each new terminal. Do not build or run
the app with sudo. The runtime remains Mono; .NET SDK is the compiler/build
tool. A desktop X11 session or XWayland is required to launch the app.

## 2. Clone the project

```bash
cd ~
git clone --branch airview/linux-development https://github.com/Varunkumar4151/AVRMissionPlanner.git
cd AVRMissionPlanner
```

If already cloned, use `git status`, then `git fetch origin` and
`git switch airview/linux-development`, followed by `git pull --ff-only`.
Preserve local edits before switching branches. The Linux build selects
desktop dependency targets and does not require the Mono source submodule.

## 3. Build and run

```bash
cd ~/AVRMissionPlanner
export DOTNET_ROOT="$HOME/.dotnet"
export PATH="$DOTNET_ROOT:$PATH"
set -o pipefail
./Linux/build.sh 2>&1 | tee "$HOME/avr-missionplanner-build.log"
```

Only after a successful build:

```bash
./Linux/run.sh
```

Output:

- `bin/linux/AVRMissionPlanner-linux-x86_64/` — runnable application.
- `bin/linux/AVRMissionPlanner-linux-x86_64.tar.gz` — complete package.
- `bin/linux/AVRMissionPlanner-linux-x86_64.tar.gz.sha256` — checksum.
- `~/avr-missionplanner-build.log` — build diagnostic log.

The package includes a Mono compiler helper for XML serialization and Mono
facades. System Mono, libgdiplus and fonts are still required. Upstream and
Mono license notices are included. The application currently uses the
Mission Planner UI and branding; AVR is the project/package name.

## Verification and troubleshooting

If compilation fails, share the end of the build log:

```bash
tail -n 100 ~/avr-missionplanner-build.log
```

After launch succeeds, an optional runtime check is available:

```bash
./Linux/run.sh --self-test
```

It uses a temporary application profile and checks FlightData action
controls, native Skia drawing, and XML theme serialization. It does not
connect to a vehicle and is not a flight-readiness test.

Serial devices need the appropriate device permissions. On Ubuntu, if your
user is not already in the `dialout` group, add it and log out/in:

```bash
sudo usermod -aG dialout "$USER"
```

Optional camera/video support requires GStreamer and separate validation.
Use new AVR builds for updates; upstream update buttons still point to
ArduPilot releases and can replace this development application.
