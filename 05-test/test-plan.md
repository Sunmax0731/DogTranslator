# DogTranslator Test Plan

## 1. Scope
Validate the Windows MVP+ across forward interpretation, settings/profile flows, history replay, local inference bridging, and Windows desktop build success.

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
9. Hover each result chip and confirm a tooltip appears.
10. Apply a feedback label via radio buttons.
11. Search the history panel and confirm matching items filter correctly.
12. Confirm history shows date and time.
13. Click a saved forward session and confirm recording replay starts.
14. Add the latest recording as a calibration sample to a profile from Settings.
15. Change the app theme preset in Settings.
16. Change the inference model in Settings and confirm the status text updates.
17. Optional: confirm `dog2vec_runtime.json` is present and the provider label resolves to local runtime when enabled.

## 4. Runtime Validation Commands
- Working directory: repository root
- `flutter analyze`
- `flutter test`
- `flutter build windows`
- `python dog_voice_local/app/infer.py --input dog_voice_local/sample_test.wav`

## 5. Expected Results
- Tests pass without compilation errors.
- Windows build completes successfully.
- Visible UI is forward-focused and no reverse tab appears.
- The app persists profiles, history, and settings locally.
- The app replays saved forward recordings from history.
- The app handles missing or weak audio gracefully.
- The local Dog2vec runtime can execute when configured.

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
- Dog2vec base weight file downloaded to `dog_voice_local/models/dog2vec/dog2vec_130k_9.pt`
- Release executable generated at `build/windows/x64/runner/Release/dog_translator.exe`
