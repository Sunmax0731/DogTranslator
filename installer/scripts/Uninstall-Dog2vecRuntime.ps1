param(
  [Parameter(Mandatory = $true)]
  [string]$RuntimeRoot,
  [Parameter(Mandatory = $true)]
  [string]$ConfigRoot
)

$ErrorActionPreference = "Stop"

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

[Environment]::SetEnvironmentVariable("DOG_TRANSLATOR_RUNTIME_ROOT", $null, "User")
[Environment]::SetEnvironmentVariable("DOG_TRANSLATOR_RUNTIME_CONFIG", $null, "User")
Broadcast-EnvironmentChange

if (Test-Path $ConfigRoot) {
  Remove-Item -Recurse -Force $ConfigRoot
}

if (Test-Path $RuntimeRoot) {
  Remove-Item -Recurse -Force $RuntimeRoot
}
