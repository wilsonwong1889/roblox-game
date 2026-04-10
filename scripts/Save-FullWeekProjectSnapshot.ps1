param(
    [Parameter(Mandatory = $true)]
    [ValidateRange(1, 99)]
    [int]$WeekNumber,

    [switch]$Force
)

$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$snapshotsRoot = Join-Path $projectRoot "FullProjectSnapshots"
$destinationRoot = Join-Path $snapshotsRoot ("Week{0}" -f $WeekNumber)

$excludedNames = @(
    ".git",
    ".vscode",
    "FullProjectSnapshots"
)

New-Item -ItemType Directory -Force -Path $snapshotsRoot | Out-Null

if (Test-Path $destinationRoot) {
    if (-not $Force) {
        throw "Full project snapshot already exists: $destinationRoot. Re-run with -Force to replace it."
    }

    Remove-Item $destinationRoot -Recurse -Force
}

New-Item -ItemType Directory -Force -Path $destinationRoot | Out-Null

$itemsToCopy = Get-ChildItem -LiteralPath $projectRoot -Force | Where-Object {
    $item = $_

    if ($excludedNames -contains $item.Name) {
        return $false
    }

    if ($item.Name -like "*.lock") {
        return $false
    }

    return $true
}

foreach ($item in $itemsToCopy) {
    Copy-Item -LiteralPath $item.FullName -Destination $destinationRoot -Recurse -Force
}

Write-Host "Saved full project snapshot:" $destinationRoot
