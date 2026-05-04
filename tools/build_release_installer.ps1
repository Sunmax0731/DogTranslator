param(
  [string]$Configuration = "Release"
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repoRoot

function Get-AppVersion {
  $pubspec = Get-Content (Join-Path $repoRoot "pubspec.yaml")
  $versionLine = $pubspec | Where-Object { $_ -match '^version:\s*' } | Select-Object -First 1
  if (-not $versionLine) {
    throw "pubspec.yaml does not contain a version field."
  }
  return (($versionLine -replace '^version:\s*', '').Split('+')[0]).Trim()
}

$iscc = Get-Command ISCC -ErrorAction SilentlyContinue
$isccPath = $null
if ($iscc) {
  $isccPath = $iscc.Source
} else {
  $defaultCandidates = @(
    "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
    "${env:ProgramFiles}\Inno Setup 6\ISCC.exe",
    "${env:LOCALAPPDATA}\Programs\Inno Setup 6\ISCC.exe"
  )
  $isccPath = $defaultCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
}

if (-not $isccPath) {
  throw "ISCC was not found. Install Inno Setup 6 first."
}

$version = Get-AppVersion
Write-Host "Building Windows app for version $version"
flutter build windows

Write-Host "Compiling installer"
& $isccPath "/DAppVersion=$version" (Join-Path $repoRoot "installer\\DogTranslator.iss")
