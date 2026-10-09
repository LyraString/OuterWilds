param(
    [string]$DeveloperKey,
    [string]$SdkPath,
    [switch]$DebugBuild
)

$ErrorActionPreference = 'Stop'
$taskRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))

if (-not $SdkPath) {
    $taskSdkConfig = Join-Path $env:APPDATA 'Garmin\ConnectIQ\current-sdk.cfg'
    if (-not (Test-Path -LiteralPath $taskSdkConfig)) {
        throw 'Install a Connect IQ SDK using Garmin SDK Manager, or pass -SdkPath.'
    }
    $SdkPath = (Get-Content -LiteralPath $taskSdkConfig -Raw).Trim()
}

if (-not $DeveloperKey) {
    $taskSettingsPath = Join-Path $env:APPDATA 'Code\User\settings.json'
    if (Test-Path -LiteralPath $taskSettingsPath) {
        $taskSettingsText = Get-Content -LiteralPath $taskSettingsPath -Raw
        $taskKeyMatch = [regex]::Match($taskSettingsText, '"monkeyC\.developerKeyPath"\s*:\s*("(?:\\.|[^"\\])*")')
        if ($taskKeyMatch.Success) {
            $DeveloperKey = ConvertFrom-Json $taskKeyMatch.Groups[1].Value
        }
    }
}
if (-not $DeveloperKey -or -not (Test-Path -LiteralPath $DeveloperKey)) {
    throw 'Pass -DeveloperKey with the path to your Garmin developer key, or configure monkeyC.developerKeyPath in VS Code.'
}

$taskCompiler = Join-Path $SdkPath 'bin\monkeyc.bat'
if (-not (Test-Path -LiteralPath $taskCompiler)) { throw 'The Connect IQ compiler was not found at -SdkPath.' }
$taskOutputDir = Join-Path $taskRoot $(if ($DebugBuild) { 'bin' } else { 'dist' })
New-Item -ItemType Directory -Path $taskOutputDir -Force | Out-Null
$taskOutput = Join-Path $taskOutputDir $(if ($DebugBuild) { 'CampfireUnderStars.prg' } else { 'CampfireUnderStars-fenix7pro.prg' })
$taskCompilerArgs = @('-f', (Join-Path $taskRoot 'monkey.jungle'), '-d', 'fenix7pro', '-y', $DeveloperKey, '-o', $taskOutput, '-w')
if (-not $DebugBuild) { $taskCompilerArgs += '-r' }

Push-Location -LiteralPath $taskRoot
try {
    & $taskCompiler @taskCompilerArgs
    if ($LASTEXITCODE -ne 0) { throw "Connect IQ compilation failed (exit $LASTEXITCODE)." }
    Write-Output "Built: $taskOutput"
} finally {
    Pop-Location
}
