param(
    [Parameter(Mandatory = $true)]
    [ValidateRange(1, 99)]
    [int]$WeekNumber,

    [switch]$Force
)

$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$weeksRoot = Join-Path $projectRoot "Weeks"
$weekFolder = Join-Path $weeksRoot ("Week{0}" -f $WeekNumber)
$sourceRoot = Join-Path $projectRoot "src"
$destinationRoot = Join-Path $weekFolder "src"

if (-not (Test-Path $sourceRoot)) {
    throw "Source folder not found: $sourceRoot"
}

New-Item -ItemType Directory -Force -Path $weeksRoot | Out-Null
New-Item -ItemType Directory -Force -Path $weekFolder | Out-Null

if (Test-Path $destinationRoot) {
    if (-not $Force) {
        throw "Week source snapshot already exists: $destinationRoot. Re-run with -Force to replace it."
    }

    Remove-Item $destinationRoot -Recurse -Force
}

Copy-Item $sourceRoot $destinationRoot -Recurse -Force

Write-Host "Saved week source snapshot:" $destinationRoot
