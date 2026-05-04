# DogTranslator Release Plan

## 1. Release Target
Ship DogTranslator as a Windows per-user installer that keeps the base app package lighter by bootstrapping Dog2vec runtime assets after installation.

## 2. Packaging Options
### Option A: Zip of Flutter build output only
- Pros: simplest to produce
- Cons: no guided setup, no runtime provisioning, poor uninstall story

### Option B: Installer with bundled app and post-install runtime bootstrap
- Pros: guided install, can download large model separately, can automate config and cleanup
- Cons: install requires internet and takes longer

### Option C: Installer with fully bundled model and Python runtime
- Pros: fully offline install after download
- Cons: installer becomes very large and awkward to distribute

## 3. Decision
- Chosen option: `Option B`

## 4. Why
- The user explicitly requested an installer path instead of a heavy bundled model package.
- Dog2vec model weights and Python ML dependencies are large enough that a bootstrap step is more practical than shipping everything inside the base installer.
- Installer + bootstrap gives a cleaner place to automate config creation and uninstall cleanup.

## 5. Release Contents
### Bundled in installer
- Windows Flutter desktop build output
- `README.md`
- bootstrap-only Dog2vec runtime sources:
  - `dog_voice_local/app/infer.py`
  - `dog_voice_local/release-requirements.txt`
  - `dog_voice_local/sample_test.wav`
- installer scripts:
  - `installer/scripts/Install-Dog2vecRuntime.ps1`
  - `installer/scripts/Uninstall-Dog2vecRuntime.ps1`

### Downloaded during install
- embedded Python runtime
- Python packages for Dog2vec local inference
- upstream Dog2vec helper code archive
- Dog2vec weight file

## 6. Installer Behavior
1. Copy app files to `%LocalAppData%\Programs\DogTranslator`
2. Run post-install PowerShell bootstrap
3. Bootstrap creates runtime workspace under `%LocalAppData%\DogTranslator\dog2vec-runtime`
4. Bootstrap writes runtime config under `%LocalAppData%\DogTranslator\.dog2vec\dog2vec_runtime.json`
5. Bootstrap sets user environment variables used for runtime discovery
6. Bootstrap runs a smoke check with the bundled sample WAV

## 7. Uninstall Behavior
- Remove installer-created runtime config
- Remove downloaded runtime assets and model data
- Remove user environment variables:
  - `DOG_TRANSLATOR_RUNTIME_ROOT`
  - `DOG_TRANSLATOR_RUNTIME_CONFIG`

## 8. Versioning
- Release version: `1.0.0`
- Flutter package version source: [pubspec.yaml](D:/AI/WinApp/DogTranslator/pubspec.yaml)
- Installer filename pattern: `DogTranslator-Setup-1.0.0.exe`

## 9. Validation Required Before Public Distribution
- `flutter analyze`
- `flutter test`
- `flutter build windows`
- `powershell -ExecutionPolicy Bypass -NoProfile -File tools/build_release_installer.ps1`
- Manual clean-profile install and uninstall smoke test

## 10. Known Distribution Constraints
- Installer requires internet access to provision Dog2vec local runtime
- First install can take noticeable time because Python dependencies and model assets are downloaded
- Dog2vec local runtime still uses the base embedding model without a product-specific learned classifier head

## 11. Post-Release Backlog
- Android delivery path
- iPhone delivery path
- product-specific Dog2vec classifier head
- clean-machine installer QA on multiple Windows devices
- optional offline redistribution strategy for enterprise or closed-network use
