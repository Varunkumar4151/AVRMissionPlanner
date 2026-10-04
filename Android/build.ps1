param([switch]$CheckOnly)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
Set-Location $root
$msbuildCommand = Get-Command msbuild -ErrorAction SilentlyContinue
if ($msbuildCommand) {
    $msbuild = $msbuildCommand.Source
} else {
    $vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
    if (!(Test-Path $vswhere)) { throw 'Visual Studio MSBuild with legacy Xamarin.Android tooling is required.' }
    $msbuild = & $vswhere -latest -requires Microsoft.Component.MSBuild -find 'MSBuild\Current\Bin\MSBuild.exe' | Select-Object -First 1
    if (!$msbuild) { throw 'MSBuild was not found.' }
}
& $msbuild Android/check-toolchain.proj -nologo -v:minimal -t:Check
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
if ($CheckOnly) { Write-Host 'Xamarin targets found. Full SDK/JDK and compilation remain to be checked.'; exit 0 }
$sdk = $env:ANDROID_SDK_ROOT
if (!$sdk) { $sdk = $env:ANDROID_HOME }
if (!$sdk -or !(Test-Path "$sdk/platforms/android-33/android.jar")) { throw 'Set ANDROID_SDK_ROOT to an Android SDK containing android-33.' }
if (!$env:JAVA_HOME -or !(Test-Path "$env:JAVA_HOME/bin/javac.exe")) { throw 'Set JAVA_HOME to a compatible JDK; upstream uses JDK 11.' }
if (!(Test-Path 'ExtLibs/mono/mcs/class/System.Windows.Forms/System.Windows.Forms-net_4_x.csproj')) {
    throw 'Run: git submodule update --init ExtLibs/mono'
}
$output = Join-Path $root 'bin/android'
New-Item -ItemType Directory -Force $output | Out-Null
& $msbuild ExtLibs/Xamarin/Xamarin.Android/Xamarin.Android.csproj -nologo -restore -t:SignAndroidPackage `
    -p:Configuration=Debug -p:AndroidPackageFormat=apk -p:AndroidCreatePackagePerAbi=false `
    -p:AndroidUseSharedRuntime=false -p:EmbedAssembliesIntoApk=true -p:AndroidLinkMode=None `
    -p:AotAssemblies=false -p:AndroidKeyStore=false "-p:AndroidSdkDirectory=$sdk" `
    "-p:JavaSdkDirectory=$env:JAVA_HOME" "-p:OutputPath=$output/" 2>&1 | Tee-Object "$output/build.log"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
$apks = @(Get-ChildItem $output -File -Filter '*-Signed.apk')
if ($apks.Count -ne 1) { throw "Expected one signed APK, found $($apks.Count). See bin/android/build.log" }
Write-Host "Development APK: $($apks[0].FullName)"
Write-Host 'Debug signing only; installation and device testing are still required.'
