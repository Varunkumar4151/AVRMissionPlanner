# AVR Mission Planner — Linux development baseline

This is a separate project for AirView Robotics development work.

- Upstream: https://github.com/ArduPilot/MissionPlanner
- Stable base: `MissionPlanner1.3.83`
- Base commit: `b78a7495fec69793f2fcc13be4b6a3d9e06b3e4e`
- Repository: https://github.com/Varunkumar4151/AVRMissionPlanner
- Development branch: `airview/linux-development`
- First runtime target: Ubuntu 24.04 x86_64 with Mono and X11/XWayland.
- Android: a later development phase, not built by this workflow.

## Build method

The stable release uses a Windows/Visual Studio build and runs on Linux with
Mono. The workflow compiles the actual source on a Windows runner, packages
that output on Ubuntu, and checks startup under a virtual X display. It does
not download a prebuilt upstream executable. This is not a native Linux ELF
application or a claim that the stable source compiles directly on Linux.

Open the repository's Actions tab. If GitHub has disabled workflows for the
new fork, enable them first. The `AVR Linux Package` workflow runs on pushes
to `airview/linux-development`. Its workflow file must be on the default
branch for GitHub to show a manual Run workflow button; otherwise a new push
to the development branch triggers it after Actions is enabled.

Only a successful `AVR Linux Package` run publishes the final
`AVRMissionPlanner-linux-x86_64` artifact. Download and extract that artifact
ZIP to obtain the tar archive and checksum. Review the separate startup
evidence artifact before using the application.

## Run on Ubuntu

```bash
sudo apt update
sudo apt install mono-complete libgdiplus fonts-dejavu-core
sha256sum -c AVRMissionPlanner-linux-x86_64.tar.gz.sha256
tar -xzf AVRMissionPlanner-linux-x86_64.tar.gz
./AVRMissionPlanner-linux-x86_64/run-avr.sh
```

Run as your normal desktop user. Serial devices need the appropriate device
permissions; on Ubuntu this commonly means membership in the `dialout` group.
Optional video features need GStreamer and must be checked separately.

## Checkout for development

```bash
git clone --branch airview/linux-development https://github.com/Varunkumar4151/AVRMissionPlanner.git
cd AVRMissionPlanner
git submodule update --init
```

The initial branch preserves upstream flight logic and UI. AVR is currently
the project/package name; the application screens still use Mission Planner
branding. Existing upstream update buttons point at upstream releases: do
not use them to update this development package. Replace the whole package
with a newer AVR build instead.

## Validation scope

The automated startup check confirms only that the process survives 45
seconds and a Mission Planner window exists. It saves a screenshot and logs;
it does not prove that startup dialogs are clear or that all screens work.
USB/serial, UDP/TCP telemetry, mission upload/download, parameter editing,
logs, maps, video and vehicle behaviour require further testing. There is
no flight-readiness claim.

## License and attribution

Keep the upstream `COPYING.txt`, source history and copyright notices with
the project. This is a Mission Planner derivative; upstream authorship is
retained.
