#!/usr/bin/env bash
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
if [[ ${1:-} == --help ]]; then
    echo 'Usage: Android/build.sh [--check]'
    echo 'Requires legacy Xamarin.Android MSBuild tooling; .NET 10 alone is insufficient.'
    exit 0
fi
if [[ $# -gt 1 || ( $# -eq 1 && $1 != --check ) ]]; then
    echo 'Usage: Android/build.sh [--check]' >&2
    exit 2
fi
if ! command -v msbuild >/dev/null; then
    echo 'BLOCKED: legacy MSBuild/Xamarin.Android tooling was not found.' >&2
    echo 'The .NET SDK installed for Linux desktop builds cannot build this legacy Android project.' >&2
    echo 'See Android/README.md before installing additional tooling.' >&2
    exit 1
fi
cd -- "$root"
msbuild Android/check-toolchain.proj -nologo -v:minimal -t:Check
if [[ ${1:-} == --check ]]; then
    echo 'Xamarin targets were found. A complete SDK/JDK, restore and compilation are still required.'
    exit 0
fi
for tool in java javac; do
    command -v "$tool" >/dev/null || { echo "Missing $tool (JDK required)." >&2; exit 1; }
done
sdk_dir=${ANDROID_SDK_ROOT:-${ANDROID_HOME:-}}
if [[ -z $sdk_dir || ! -f "$sdk_dir/platforms/android-33/android.jar" ]]; then
    echo 'Set ANDROID_SDK_ROOT to an Android SDK containing platform android-33.' >&2
    exit 1
fi
if [[ -z ${JAVA_HOME:-} || ! -x "$JAVA_HOME/bin/javac" ]]; then
    echo 'Set JAVA_HOME to a compatible JDK; upstream uses JDK 11.' >&2
    exit 1
fi
if [[ ! -f ExtLibs/mono/mcs/class/System.Windows.Forms/System.Windows.Forms-net_4_x.csproj ]]; then
    echo 'Initialize the required source submodule: git submodule update --init ExtLibs/mono' >&2
    exit 1
fi
output="$root/bin/android"
mkdir -p "$output"
msbuild ExtLibs/Xamarin/Xamarin.Android/Xamarin.Android.csproj \
    -nologo -restore -t:SignAndroidPackage -p:Configuration=Debug \
    -p:AndroidPackageFormat=apk -p:AndroidCreatePackagePerAbi=false \
    -p:AndroidUseSharedRuntime=false -p:EmbedAssembliesIntoApk=true \
    -p:AndroidLinkMode=None -p:AotAssemblies=false -p:AndroidKeyStore=false \
    "-p:AndroidSdkDirectory=$sdk_dir" "-p:JavaSdkDirectory=$JAVA_HOME" \
    "-p:OutputPath=$output/" 2>&1 | tee "$output/build.log"
mapfile -t apks < <(find "$output" -maxdepth 1 -type f -name '*-Signed.apk')
if [[ ${#apks[@]} -ne 1 ]]; then
    echo "Expected one signed APK, found ${#apks[@]}. Check $output/build.log" >&2
    exit 1
fi
echo "Development APK: ${apks[0]}"
echo 'Debug signing only; installation and device testing are still required.'
