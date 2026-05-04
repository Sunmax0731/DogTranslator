param(
  [Parameter(Mandatory = $true)]
  [string]$AppInstallDir,
  [Parameter(Mandatory = $true)]
  [string]$RuntimeRoot,
  [Parameter(Mandatory = $true)]
  [string]$ConfigRoot,
  [string]$PythonVersion = "3.10.11",
  [string]$PythonEmbedUrl = "https://www.python.org/ftp/python/3.10.11/python-3.10.11-embed-amd64.zip",
  [string]$GetPipUrl = "https://bootstrap.pypa.io/get-pip.py",
  [string]$VendorZipUrl = "https://github.com/fispresent/dog2vec/archive/refs/heads/main.zip",
  [string]$ModelUrl = "https://zenodo.org/records/15494042/files/dog2vec_130k_9.pt?download=1"
)

$ErrorActionPreference = "Stop"

function Write-Log {
  param([string]$Message)
  $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
  Write-Host "[$timestamp] $Message"
}

function Ensure-Directory {
  param([string]$Path)
  New-Item -ItemType Directory -Force -Path $Path | Out-Null
}

function Download-File {
  param(
    [string]$Url,
    [string]$Destination
  )
  Write-Log "Downloading $Url"
  Invoke-WebRequest -Uri $Url -OutFile $Destination
}

function Expand-ZipTo {
  param(
    [string]$ZipPath,
    [string]$Destination
  )
  if (Test-Path $Destination) {
    Remove-Item -Recurse -Force $Destination
  }
  Ensure-Directory $Destination
  Expand-Archive -Path $ZipPath -DestinationPath $Destination -Force
}

function Enable-EmbeddedPythonSite {
  param([string]$PythonDir)
  $pth = Get-ChildItem -Path $PythonDir -Filter "python*._pth" | Select-Object -First 1
  if (-not $pth) {
    throw "Embedded Python ._pth file was not found in $PythonDir"
  }
  $lines = Get-Content $pth.FullName
  $normalized = New-Object System.Collections.Generic.List[string]
  $hasSitePackages = $false
  $hasImportSite = $false
  foreach ($line in $lines) {
    $trimmed = $line.Trim()
    if ($trimmed -eq "#import site" -or $trimmed -eq "import site") {
      $normalized.Add("import site")
      $hasImportSite = $true
      continue
    }
    if ($trimmed -eq "Lib\\site-packages") {
      $hasSitePackages = $true
    }
    $normalized.Add($line)
  }
  if (-not $hasSitePackages) {
    $normalized.Add("Lib\\site-packages")
  }
  if (-not $hasImportSite) {
    $normalized.Add("import site")
  }
  Set-Content -Path $pth.FullName -Value $normalized -Encoding UTF8
}

function Install-EmbeddedPython {
  param([string]$PythonDir)

  $pythonExe = Join-Path $PythonDir "python.exe"
  if (Test-Path $pythonExe) {
    return $pythonExe
  }

  Ensure-Directory $PythonDir
  $tempZip = Join-Path ([System.IO.Path]::GetTempPath()) "dogtranslator-python-embed.zip"
  Download-File -Url $PythonEmbedUrl -Destination $tempZip
  Expand-Archive -Path $tempZip -DestinationPath $PythonDir -Force
  Remove-Item $tempZip -Force
  Enable-EmbeddedPythonSite -PythonDir $PythonDir

  $tempGetPip = Join-Path ([System.IO.Path]::GetTempPath()) "dogtranslator-get-pip.py"
  Download-File -Url $GetPipUrl -Destination $tempGetPip
  & $pythonExe $tempGetPip
  Remove-Item $tempGetPip -Force

  & $pythonExe -m pip install --upgrade pip setuptools wheel
  return $pythonExe
}

function Install-PythonDependencies {
  param(
    [string]$PythonExe,
    [string]$RequirementsPath
  )
  & $PythonExe -m pip install --extra-index-url https://download.pytorch.org/whl/cpu -r $RequirementsPath
}

function Install-VendorRepo {
  param([string]$VendorRoot)
  $repoDir = Join-Path $VendorRoot "dog2vec"
  if (Test-Path $repoDir) {
    return
  }

  Ensure-Directory $VendorRoot
  $tempZip = Join-Path ([System.IO.Path]::GetTempPath()) "dogtranslator-dog2vec.zip"
  $tempExtract = Join-Path ([System.IO.Path]::GetTempPath()) "dogtranslator-dog2vec-extract"
  Download-File -Url $VendorZipUrl -Destination $tempZip
  Expand-ZipTo -ZipPath $tempZip -Destination $tempExtract
  $expandedRepo = Get-ChildItem $tempExtract -Directory | Select-Object -First 1
  if (-not $expandedRepo) {
    throw "Failed to extract dog2vec vendor archive."
  }
  Move-Item -Path $expandedRepo.FullName -Destination $repoDir
  Remove-Item $tempZip -Force
  Remove-Item $tempExtract -Recurse -Force
}

function Install-ModelFile {
  param([string]$ModelPath)
  if (Test-Path $ModelPath) {
    return
  }
  Ensure-Directory (Split-Path -Parent $ModelPath)
  Download-File -Url $ModelUrl -Destination $ModelPath
}

function Broadcast-EnvironmentChange {
  Add-Type -Namespace Win32 -Name NativeMethods -MemberDefinition @"
[DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
public static extern IntPtr SendMessageTimeout(
  IntPtr hWnd,
  uint Msg,
  UIntPtr wParam,
  string lParam,
  uint fuFlags,
  uint uTimeout,
  out UIntPtr lpdwResult);
"@
  $result = [UIntPtr]::Zero
  [void][Win32.NativeMethods]::SendMessageTimeout(
    [IntPtr]0xffff,
    0x001A,
    [UIntPtr]::Zero,
    "Environment",
    0x0002,
    5000,
    [ref]$result
  )
}

function Set-UserEnvironmentVariable {
  param(
    [string]$Name,
    [string]$Value
  )
  [Environment]::SetEnvironmentVariable($Name, $Value, "User")
}

$AppInstallDir = (Resolve-Path $AppInstallDir).Path
$RuntimeRoot = [System.IO.Path]::GetFullPath($RuntimeRoot)
$ConfigRoot = [System.IO.Path]::GetFullPath($ConfigRoot)
$RuntimeWorkingDir = Join-Path $RuntimeRoot "dog_voice_local"
$BootstrapSource = Join-Path $AppInstallDir "dog_voice_local"
$PythonDir = Join-Path $RuntimeRoot "python"
$VendorRoot = Join-Path $RuntimeWorkingDir "vendor"
$ModelPath = Join-Path $RuntimeWorkingDir "models\\dog2vec\\dog2vec_130k_9.pt"
$ConfigPath = Join-Path $ConfigRoot "dog2vec_runtime.json"
$RequirementsPath = Join-Path $RuntimeWorkingDir "release-requirements.txt"
$SmokeWav = Join-Path $RuntimeWorkingDir "sample_test.wav"

Write-Log "Preparing Dog2vec runtime bootstrap under $RuntimeRoot"
Ensure-Directory $RuntimeRoot
Ensure-Directory $ConfigRoot

if (-not (Test-Path $BootstrapSource)) {
  throw "Bundled dog_voice_local bootstrap files were not found at $BootstrapSource"
}

if (Test-Path $RuntimeWorkingDir) {
  Remove-Item -Recurse -Force $RuntimeWorkingDir
}
Copy-Item -Recurse -Force $BootstrapSource $RuntimeWorkingDir
if (Test-Path (Join-Path $RuntimeWorkingDir "models")) {
  Remove-Item -Recurse -Force (Join-Path $RuntimeWorkingDir "models")
}
if (Test-Path (Join-Path $RuntimeWorkingDir "vendor")) {
  Remove-Item -Recurse -Force (Join-Path $RuntimeWorkingDir "vendor")
}

$pythonExe = Install-EmbeddedPython -PythonDir $PythonDir
Install-PythonDependencies -PythonExe $pythonExe -RequirementsPath $RequirementsPath
Install-VendorRepo -VendorRoot $VendorRoot
Install-ModelFile -ModelPath $ModelPath

$runtimeConfig = @{
  enabled = $true
  command = $pythonExe
  args = @("app/infer.py")
  workingDirectory = $RuntimeWorkingDir
  timeoutMs = 15000
} | ConvertTo-Json -Depth 4
Set-Content -Path $ConfigPath -Value $runtimeConfig -Encoding UTF8

Set-UserEnvironmentVariable -Name "DOG_TRANSLATOR_RUNTIME_ROOT" -Value $RuntimeRoot
Set-UserEnvironmentVariable -Name "DOG_TRANSLATOR_RUNTIME_CONFIG" -Value $ConfigPath
Broadcast-EnvironmentChange

if (-not (Test-Path $SmokeWav)) {
  throw "Smoke-test sample WAV was not found at $SmokeWav"
}

Write-Log "Running Dog2vec runtime smoke test"
$smokeOutput = & $pythonExe (Join-Path $RuntimeWorkingDir "app\\infer.py") --input $SmokeWav
if (-not $smokeOutput) {
  throw "Dog2vec runtime smoke test returned no output."
}
$parsed = $smokeOutput | ConvertFrom-Json
if (-not $parsed.runtime) {
  throw "Dog2vec runtime smoke test output did not include runtime metadata."
}

Write-Log "Dog2vec runtime install completed"
