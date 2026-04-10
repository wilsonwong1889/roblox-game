$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$rojo = "C:\Users\wilso\AppData\Local\Microsoft\WinGet\Packages\Rojo.Rojo_Microsoft.Winget.Source_8wekyb3d8bbwe\rojo.exe"
$outputFile = Join-Path $projectRoot "build-smoke-test.rbxlx"

$requiredFiles = @(
    "default.project.json",
    "src\ReplicatedStorage\Modules\GameConfig.luau",
    "src\ReplicatedStorage\Modules\PlayerProfile.luau",
    "src\ReplicatedStorage\Modules\SecondFloorConfig.luau",
    "src\ReplicatedStorage\Modules\ThirdFloorConfig.luau",
    "src\ServerScriptService\MainServer.server.luau",
    "src\ServerScriptService\StartupGuard.server.luau",
    "src\ServerScriptService\Services\SaveService.luau",
    "src\ServerScriptService\Services\RebirthService.luau",
    "src\ServerScriptService\Services\RaidService.luau",
    "src\ServerScriptService\Services\Tycoon.luau",
    "src\ServerScriptService\Services\TycoonOwnershipRegistry.luau",
    "src\ServerScriptService\Services\TycoonService.luau",
    "src\ServerScriptService\Services\SelfTestService.luau",
    "src\ServerScriptService\Services\WeaponService.luau",
    "src\StarterGui\MainClient.client.luau",
    "src\Workspace\TycoonModels.luau",
    "src\ServerStorage\TycoonAssets.luau",
    "WEEK4_BLUEPRINT.md",
    "Week6\README.md",
    "Week6\TEST_CASES.md",
    "Weeks\Week6\src"
)

foreach ($relativePath in $requiredFiles) {
    $fullPath = Join-Path $projectRoot $relativePath
    if (-not (Test-Path $fullPath)) {
        throw "Missing required file: $relativePath"
    }
}

$projectJson = Get-Content (Join-Path $projectRoot "default.project.json") -Raw | ConvertFrom-Json
if (-not $projectJson.tree.Workspace) {
    throw "Rojo project is missing Workspace mapping."
}

if (-not $projectJson.tree.ServerStorage) {
    throw "Rojo project is missing ServerStorage mapping."
}

Push-Location $projectRoot
try {
    if (Test-Path $outputFile) {
        Remove-Item $outputFile -Force
    }

    & $rojo build "default.project.json" -o $outputFile

    if (-not (Test-Path $outputFile)) {
        throw "Rojo did not produce the expected output file."
    }

    $size = (Get-Item $outputFile).Length
    if ($size -le 0) {
        throw "Rojo build produced an empty place file."
    }

    Write-Host "Smoke test passed. Rojo build completed successfully."
}
finally {
    if (Test-Path $outputFile) {
        Remove-Item $outputFile -Force
    }

    Pop-Location
}
