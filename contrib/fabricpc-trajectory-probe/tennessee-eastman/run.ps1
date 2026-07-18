param(
    [string]$Archive = "C:\tmp\TEdata.zip",
    [string]$WorkDir = "C:\tmp\tep-paired",
    [string]$Output = ""
)

$ErrorActionPreference = "Stop"
$ExpectedSha256 = "0ff82bbdef0f5f52746c8a03b2a9645f656dbee3cd57587d15a4963087d233db"
$DownloadUrl = "https://data.mendeley.com/public-files/datasets/g2st27k8ww/files/1e1fd5e2-4d70-41f7-8fc7-d42ebbf749eb/file_downloaded"
$PackageDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Root = (Resolve-Path (Join-Path $PackageDir "..\..\..")).Path
if (-not $Output) {
    $Output = Join-Path $Root "verification\tep_fault1_certificate.json"
}

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Archive) |
    Out-Null
if (-not (Test-Path -LiteralPath $Archive)) {
    Write-Host "Downloading the public Tennessee Eastman archive..."
    curl.exe -L $DownloadUrl -o $Archive
    if ($LASTEXITCODE -ne 0) {
        throw "Dataset download failed with exit code $LASTEXITCODE"
    }
}

$ActualSha256 = (
    Get-FileHash -Algorithm SHA256 -LiteralPath $Archive
).Hash.ToLowerInvariant()
if ($ActualSha256 -ne $ExpectedSha256) {
    throw "Dataset hash mismatch: expected $ExpectedSha256, got $ActualSha256"
}

$ResolvedWorkParent = (
    Resolve-Path -LiteralPath (Split-Path -Parent $WorkDir)
).Path
$ResolvedTmp = (Resolve-Path -LiteralPath "C:\tmp").Path
if (-not $ResolvedWorkParent.StartsWith(
    $ResolvedTmp,
    [System.StringComparison]::OrdinalIgnoreCase
)) {
    throw "WorkDir must remain under C:\tmp"
}
if (Test-Path -LiteralPath $WorkDir) {
    Remove-Item -LiteralPath $WorkDir -Recurse -Force
}

$ExtractDir = Join-Path $WorkDir "source"
$NormalDir = Join-Path $WorkDir "normal"
$FaultDir = Join-Path $WorkDir "fault1"
New-Item -ItemType Directory -Force -Path $ExtractDir, $NormalDir, $FaultDir |
    Out-Null
tar -xf $Archive -C $ExtractDir
if ($LASTEXITCODE -ne 0) {
    throw "Dataset extraction failed with exit code $LASTEXITCODE"
}
$SourceDir = Join-Path $ExtractDir "TEdata"

$Fortran = (Get-Command gfortran -ErrorAction Stop).Source
foreach ($Run in @(
    @{ Name = "normal"; Directory = $NormalDir; Fault = $false },
    @{ Name = "fault1"; Directory = $FaultDir; Fault = $true }
)) {
    Copy-Item (Join-Path $SourceDir "temain_mod.f") $Run.Directory
    Copy-Item (Join-Path $SourceDir "teprob.f") $Run.Directory
    $MainPath = Join-Path $Run.Directory "temain_mod.f"
    $Source = [IO.File]::ReadAllText($MainPath)
    $Source = $Source.Replace("NPTS = 172800", "NPTS = 36000")
    $Source = $Source.Replace("FILE='~/", "FILE='")
    if ($Run.Fault) {
        $Source = $Source.Replace(
            "                 IDV(12)=1",
            "                 IDV(1)=1"
        )
    } else {
        $Source = $Source.Replace(
            "                 IDV(12)=1",
            "C                IDV(12)=1"
        )
    }
    [IO.File]::WriteAllText(
        $MainPath,
        $Source,
        [Text.Encoding]::ASCII
    )

    Push-Location $Run.Directory
    try {
        & $Fortran -std=legacy -O2 temain_mod.f teprob.f -o tep.exe
        if ($LASTEXITCODE -ne 0) {
            throw "$($Run.Name) compilation failed"
        }
        & (Join-Path $Run.Directory "tep.exe")
        if ($LASTEXITCODE -ne 0) {
            throw "$($Run.Name) simulation failed"
        }
    } finally {
        Pop-Location
    }
}

python (Join-Path $Root "verification\tools\tep_trajectory_probe.py") `
    --normal-dir $NormalDir `
    --fault-dir $FaultDir `
    --intervention-index 160 `
    --output $Output
if ($LASTEXITCODE -ne 0) {
    throw "Trajectory certificate failed with exit code $LASTEXITCODE"
}

$FabricPython = Join-Path $Root "fabric\FabricPC\.venv\Scripts\python.exe"
if (-not (Test-Path -LiteralPath $FabricPython)) {
    throw "Pinned FabricPC environment not found at $FabricPython"
}
$PreviousPythonPath = $env:PYTHONPATH
try {
    $env:PYTHONPATH = Join-Path $Root "fabric\FabricPC"
    & $FabricPython `
        (Join-Path $Root "verification\tools\tep_fabricpc_predictive_coding.py") `
        --normal-dir $NormalDir `
        --fault-dir $FaultDir `
        --output (Join-Path $Root "verification\tep_fabricpc_predictive_coding.json")
    if ($LASTEXITCODE -ne 0) {
        throw "FabricPC experiment failed with exit code $LASTEXITCODE"
    }
} finally {
    $env:PYTHONPATH = $PreviousPythonPath
}

Write-Host "Tennessee Eastman certificate -> $Output"
Write-Host (
    "FabricPC certificate -> " +
    (Join-Path $Root "verification\tep_fabricpc_predictive_coding.json")
)
