# AVR Mission Planner Android development

Branch: `airview/android-development`, based on `airview/linux-development`
at `750423ca307790c73f1c6e90f6e2ed156abb09a5` (stable Mission Planner 1.3.83
plus desktop Linux compatibility changes).

Application ID: `com.airviewrobotics.avrmissionplanner`.
Launcher name: **AVR Mission Planner**.
Version: `1.3.83-avr.1` / version code `1`.

This branch prepares an installable, debug-signed APK configuration. No APK
has been compiled or tested for this branch yet. Branding/icon artwork inside
the existing UI is still inherited from Mission Planner. Upstream attribution
and licensing are retained. Linux-only startup/layout helpers and tests are
excluded from the mobile library build.

## Toolchain blocker

The upstream Android application is a legacy Xamarin.Android project
(`TargetFrameworkVersion=v13.0`) using Xamarin.Forms 5 and Android bindings.
Installing .NET 10 and `dotnet workload install android` does not convert it
into a modern .NET Android application. Xamarin support has ended:
https://dotnet.microsoft.com/en-us/platform/support/policy/xamarin

The Linux desktop SDK instructions are not Android build instructions.
An existing compatible Xamarin.Android/MSBuild environment is required.
Current Windows hosted runners may also lack these legacy components; the
manual workflow checks for them and stops with a clear error. It does not
install a Xamarin toolchain. A provisioned legacy Windows environment or a
proper migration of the application and Android binding projects is still
needed if the checks fail. Do not assume an SDK download alone resolves it.

No automatic build or Play Store publishing is configured. The previous
upstream signing credentials, publishing and release actions were removed
from this branch's Android workflow.

## Check your Linux toolchain first

In a separate checkout:

```bash
git clone --branch airview/android-development https://github.com/Varunkumar4151/AVRMissionPlanner.git AVRMissionPlanner-Android
cd AVRMissionPlanner-Android
./Android/build.sh --check
```

If that reports a missing Xamarin toolchain, stop and share the output.
There is no verified current Linux bootstrap procedure in this repository.

## Build with an existing compatible environment

Requirements include legacy Xamarin.Android/MSBuild, the .NET SDK components
needed by the shared netstandard projects, Android SDK platform 33, compatible
build-tools, JDK 11, NuGet access, and the Mono source submodule. Compile SDK
remains upstream v13.0/API 33 and manifest target SDK remains upstream 35;
newer Android behaviour and native-library compatibility need device testing.

```bash
git submodule update --init ExtLibs/mono
export ANDROID_SDK_ROOT=/absolute/path/to/android-sdk
export JAVA_HOME=/absolute/path/to/jdk-11
./Android/build.sh
```

On a compatible Windows machine, set the same environment variables, then:

```powershell
git submodule update --init ExtLibs/mono
./Android/build.ps1
```

The build uses Debug, APK output, no assembly stripping/AOT, and embeds the
managed assemblies. It produces one multi-ABI development APK in `bin/android/`
and a build log. The build environment's debug keystore signs it. Keep that
keystore to install later test updates; a different signing key cannot update
an existing installation. Production signing and store distribution are not
configured.

After a successful build, install the resulting `*-Signed.apk` using ADB or
transfer it to the Android device. Verify startup, permissions, serial/USB,
Bluetooth, telemetry, mission upload/download, maps, logs and video before
using it with a vehicle. No device compatibility or flight-readiness claim
is made by these repository changes.
