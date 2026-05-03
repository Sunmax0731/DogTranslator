# Task: Windows Build Prerequisites

## Goal
Unblock `flutter build windows` on this machine.

## Current Failure
- `flutter build windows` fails because Flutter cannot find a suitable Visual Studio C++ toolchain.
- `flutter doctor -v` reports that Visual Studio Community 2026 at `C:\Program Files\Microsoft Visual Studio\18\Community` is missing:
  - `Desktop development with C++`
  - `MSVC v142 - VS 2019 C++ x64/x86 build tools`
  - `C++ CMake tools for Windows`
  - `Windows 10 SDK`

## Evidence
- `flutter doctor -v`
- Installer log: `%TEMP%\dd_installer_20260503221043.log`
- Key installer message:
  - commands with `--quiet` or `--passive` must be run elevated from the beginning
  - exit code `5007`

## Blocking Constraint
- This Codex session can invoke the Visual Studio Installer, but it cannot complete the required elevated modification flow in the current environment.
- Attempts to use scheduled tasks for silent elevation also failed with access denied.

## Manual Resolution Path
1. Open Visual Studio Installer as administrator.
2. Modify `Visual Studio Community 2026`.
3. Add the `Desktop development with C++` workload.
4. Ensure these individual components are present:
   - `MSVC v142 - VS 2019 C++ x64/x86 build tools`
   - `C++ CMake tools for Windows`
   - `Windows 10 SDK`
5. Re-run:
   - `flutter doctor -v`
   - `flutter build windows`

## Done Condition
- `flutter doctor -v` shows Visual Studio as healthy for Windows desktop development.
- `flutter build windows` completes successfully.
