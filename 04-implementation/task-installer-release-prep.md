# Task: Installer Release Preparation

## Objective
Implement the release bootstrap assets and build helper needed to produce a Windows installer.

## Implementation Scope
- Add installer definition file.
- Add post-install runtime bootstrap PowerShell script.
- Add uninstall cleanup PowerShell script.
- Add release build helper script for Windows + installer compilation.
- Add app-side runtime config discovery for installed deployments.
- Add pinned runtime dependency manifest for installer bootstrap.

## Validation
- `flutter analyze`
- `flutter test`
- `flutter build windows`
- `powershell -ExecutionPolicy Bypass -NoProfile -File tools/build_release_installer.ps1`
