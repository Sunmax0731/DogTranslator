param(
  [string]$TargetRoot = (Split-Path -Parent $PSScriptRoot),
  [switch]$DownloadModel
)

$vendorDir = Join-Path $TargetRoot "vendor"
$repoDir = Join-Path $vendorDir "dog2vec"
$modelDir = Join-Path $TargetRoot "models\\dog2vec"
$modelPath = Join-Path $modelDir "dog2vec_130k_9.pt"

New-Item -ItemType Directory -Force -Path $vendorDir | Out-Null
New-Item -ItemType Directory -Force -Path $modelDir | Out-Null

if (-not (Test-Path $repoDir)) {
  git clone --depth 1 https://github.com/fispresent/dog2vec.git $repoDir
}

if ($DownloadModel -and -not (Test-Path $modelPath)) {
  $url = "https://zenodo.org/records/15494042/files/dog2vec_130k_9.pt?download=1"
  Invoke-WebRequest -Uri $url -OutFile $modelPath
}

Write-Host "Vendor repo: $repoDir"
Write-Host "Model path : $modelPath"
