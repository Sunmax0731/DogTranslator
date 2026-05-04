# DogTranslator

DogTranslator is a Windows-first Flutter desktop application that records dog vocalizations and estimates likely emotional intent in Japanese. The visible product is intentionally focused on `forward interpretation` rather than literal translation.

## Current Product Scope
- Windows desktop app
- Dog voice recording and staged interpretation
- Local profile, history, replay, and dashboard features
- Theme, microphone, and inference model settings
- Optional Dog2vec local runtime through an external Python process
- Breed-aware expression icons for the top candidate

## Product Framing
- This app is an `interpretation` and `emotion estimation` tool.
- It does **not** claim scientifically validated literal translation of dog language.
- Reverse text-to-dog playback code remains in the repository, but the release UI does not expose it.

## Release Packaging
The release target is a Windows installer, not a plain zip-only drop.

### Installer behavior
- Installs the desktop app under `%LocalAppData%\Programs\DogTranslator`
- Bundles the Flutter app plus bootstrap-only Dog2vec runtime sources
- Downloads Dog2vec runtime assets during installation:
  - embedded Python runtime
  - Python dependencies
  - Dog2vec helper code
  - Dog2vec model weight file
- Writes runtime configuration automatically
- Removes runtime configuration and downloaded runtime assets on uninstall

### Current installer artifact
- Local build output: [dist/installer](D:/AI/WinApp/DogTranslator/dist/installer)
- Expected filename pattern: `DogTranslator-Setup-<version>.exe`

## Developer Commands
- Analyze: `flutter analyze`
- Test: `flutter test`
- Windows build: `flutter build windows`
- Build installer: `powershell -ExecutionPolicy Bypass -NoProfile -File tools/build_release_installer.ps1`

## Dog2vec Runtime Notes
- Development runtime bootstrap lives under [dog_voice_local](D:/AI/WinApp/DogTranslator/dog_voice_local)
- Release installer bootstrap scripts live under [installer/scripts](D:/AI/WinApp/DogTranslator/installer/scripts)
- App-side runtime config discovery is handled in [local_inference_runtime.dart](D:/AI/WinApp/DogTranslator/lib/services/local_inference_runtime.dart)

## Project Documents
- [ToDo.md](D:/AI/WinApp/DogTranslator/ToDo.md)
- [01-requirements/requirements-definition.md](D:/AI/WinApp/DogTranslator/01-requirements/requirements-definition.md)
- [02-specification/specification.md](D:/AI/WinApp/DogTranslator/02-specification/specification.md)
- [03-design/design.md](D:/AI/WinApp/DogTranslator/03-design/design.md)
- [04-implementation/implementation-report.md](D:/AI/WinApp/DogTranslator/04-implementation/implementation-report.md)
- [05-test/test-plan.md](D:/AI/WinApp/DogTranslator/05-test/test-plan.md)
- [06-release/release-plan.md](D:/AI/WinApp/DogTranslator/06-release/release-plan.md)
- [06-release/release-notes-v1.0.0.md](D:/AI/WinApp/DogTranslator/06-release/release-notes-v1.0.0.md)
