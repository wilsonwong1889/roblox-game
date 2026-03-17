param(
    [Parameter(Mandatory = $true)]
    [ValidateRange(1, 99)]
    [int]$WeekNumber
)

$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$backupRoot = Join-Path $projectRoot "backups"
$destination = Join-Path $backupRoot ("Week{0}" -f $WeekNumber)

if (Test-Path $destination) {
    throw "Snapshot already exists: $destination"
}

New-Item -ItemType Directory -Force -Path $backupRoot | Out-Null

$robocopyArgs = @(
    $projectRoot,
    $destination,
    "/E",
    "/R:1",
    "/W:1",
    "/NFL",
    "/NDL",
    "/NJH",
    "/NJS",
    "/XD", (Join-Path $projectRoot "backups"), (Join-Path $projectRoot ".git"),
    "/XF", "build-smoke-test.rbxlx", "build-test.rbxlx"
)

& robocopy @robocopyArgs | Out-Null
$exitCode = $LASTEXITCODE

if ($exitCode -gt 7) {
    throw "Robocopy failed with exit code $exitCode"
}

Write-Host "Created weekly snapshot:" $destination
