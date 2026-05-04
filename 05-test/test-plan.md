# DogTranslator Test Plan

## 1. Scope
Validate the Windows MVP+ across forward interpretation, settings/profile flows, progress feedback, history replay/filter/delete flows, dashboard drilldowns, local inference bridging, and Windows desktop build success.

## 2. Automated Tests
### Unit Tests
- Audio feature extraction from WAV bytes
- Intent classification from derived audio features
- Confidence and candidate ranking with extended audio features
- Reverse translator domain behavior retained in code
- Analytics summary generation
- JSON repository persistence
- Local process inference JSON mapping
- Inference model selection and fallback resolution

### Widget Tests
- Settings tab presence
- Theme / inference configuration surface rendering
- History and dashboard shell rendering through the app entrypoint

## 3. Manual Regression Checklist
1. Launch app on Windows.
2. Confirm visible navigation contains `Forward`, `Dashboard`, and `Settings`.
3. Confirm the previous reverse tab is not visible.
4. Add a dog profile from the recording-side shortcut.
5. Open Settings and confirm profile add / edit / delete are available there as well.
6. Start and stop microphone recording.
7. Confirm waveform appears during recording.
8. Confirm analysis result appears with:
   - Japanese emotion label
   - candidate pie chart
   - vocal type
   - context
   - valence / arousal hints
   - quality guidance
9. Start another analysis with Dog2vec local inference and confirm:
   - multi-step progress text appears
   - progress bar advances through several stages
   - estimated remaining time appears
   - previous result card becomes semi-transparent while analysis is active
9. Hover each result chip and confirm a tooltip appears.
10. Confirm confidence colors differ between low / medium / high outputs and that provider label is shown first.
11. Confirm bounded metrics such as RMS, Peak, Arousal, and Valence render as mini graphs.
12. Apply a feedback label via radio buttons.
13. Search the history panel and confirm matching items filter correctly.
14. Apply history intent/profile tag filters and confirm the list narrows correctly.
15. Click a saved forward session and confirm its analysis result is restored into the main result area.
16. Use the history `再生` action and confirm recording replay starts.
17. Delete one history item from the UI and confirm it disappears.
18. Use the history bulk-delete action only in a disposable test state and confirm all forward history items are removed.
19. In Dashboard, click an emotion item and confirm the history intent filter updates accordingly.
20. In Dashboard, change the profile filter and confirm metrics update for that profile only.
21. Open Settings and confirm microphone selection is available there instead of the forward tab.
22. Add the latest recording as a calibration sample to a profile from Settings.
23. Change the app theme preset in Settings, including dark mode.
24. Change the inference model in Settings and confirm the status text updates.
25. Optional: confirm `dog2vec_runtime.json` is present and the provider label resolves to local runtime when enabled.

## 4. Runtime Validation Commands
- Working directory: repository root
- `flutter analyze`
- `flutter test`
- `flutter build windows`
- `python dog_voice_local/app/infer.py --input dog_voice_local/sample_test.wav`
- `powershell -ExecutionPolicy Bypass -NoProfile -File installer/scripts/Install-Dog2vecRuntime.ps1 -?`
- `powershell -ExecutionPolicy Bypass -NoProfile -File installer/scripts/Uninstall-Dog2vecRuntime.ps1 -?`
- `powershell -ExecutionPolicy Bypass -NoProfile -File tools/build_release_installer.ps1`

## 5. Expected Results
- Tests pass without compilation errors.
- Windows build completes successfully.
- Visible UI is forward-focused and no reverse tab appears.
- The app persists profiles, history, and settings locally.
- The app replays saved forward recordings from history.
- The app restores a clicked history record into the main analysis result surface.
- The app supports history filtering by search text, inferred emotion, and profile.
- The app shows meaningful staged progress feedback during analysis.
- The app handles missing or weak audio gracefully.
- The local Dog2vec runtime can execute when configured.
- The Windows installer compiles successfully and includes runtime bootstrap scripts.

## 6. Known Risk Areas
- Real microphone device behavior may differ by hardware.
- Heuristic interpretation is intentionally approximate.
- Dog2vec runtime currently uses the base embedding model without product-specific learned classifier heads.
- Python runtime packaging for redistribution is not yet finalized.

## 7. Observed Results
- `flutter analyze`: passed
- `flutter test`: passed with 13 tests
- `flutter build windows`: passed
- `python dog_voice_local/app/infer.py --input dog_voice_local/sample_test.wav`: passed
- `powershell -ExecutionPolicy Bypass -NoProfile -File installer/scripts/Install-Dog2vecRuntime.ps1 -?`: passed
- `powershell -ExecutionPolicy Bypass -NoProfile -File installer/scripts/Uninstall-Dog2vecRuntime.ps1 -?`: passed
- `powershell -ExecutionPolicy Bypass -NoProfile -File tools/build_release_installer.ps1`: passed
- Dog2vec base weight file downloaded to `dog_voice_local/models/dog2vec/dog2vec_130k_9.pt`
- Release executable generated at `build/windows/x64/runner/Release/dog_translator.exe`
- Installer artifact generated at `dist/installer/DogTranslator-Setup-1.0.0.exe`
