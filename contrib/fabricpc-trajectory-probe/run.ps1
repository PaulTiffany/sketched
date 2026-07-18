param(
    [double]$Perturbation = 0.001,
    [int]$InferSteps = 12,
    [double]$Eta = 0.05,
    [int]$ParameterSeed = 17,
    [int]$StateSeed = 23,
    [double]$DirectionX = 1.0,
    [double]$DirectionY = 0.0,
    [switch]$Nonlinear,
    [string]$OutputDir = "C:\tmp\fabricpc-trajectory-probe"
)

$ErrorActionPreference = "Stop"
$PackageDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Root = (Resolve-Path (Join-Path $PackageDir "..\..")).Path
$Python = Join-Path $Root "fabric\FabricPC\.venv\Scripts\python.exe"
$Adapter = Join-Path $Root "verification\tools\fabricpc_orientation_adapter.py"

if (-not (Test-Path -LiteralPath $Python)) {
    throw "Pinned FabricPC Python environment not found: $Python"
}
if ($DirectionX -eq 0.0 -and $DirectionY -eq 0.0) {
    throw "Perturbation direction must be nonzero"
}

$Arguments = @(
    $Adapter,
    "--output-dir", $OutputDir,
    "--perturbation", $Perturbation,
    "--infer-steps", $InferSteps,
    "--eta", $Eta,
    "--parameter-seed", $ParameterSeed,
    "--state-seed", $StateSeed,
    "--direction", $DirectionX, $DirectionY
)
if ($Nonlinear) {
    $Arguments += "--nonlinear"
}

Write-Host "FabricPC trajectory probe"
Write-Host "  output: $OutputDir"
Write-Host "  seeds: parameters=$ParameterSeed state=$StateSeed"
Write-Host "  direction: ($DirectionX, $DirectionY) nonlinear=$($Nonlinear.IsPresent)"
& $Python @Arguments
if ($LASTEXITCODE -ne 0) {
    throw "Probe failed with exit code $LASTEXITCODE"
}
