# DogTranslator Test Plan

## 1. Scope
Validate the Windows MVP+ across domain logic, persistence, primary UI flows, local inference bridging, and Windows desktop build success.

## 2. Automated Tests
### Unit Tests
- Audio feature extraction from WAV bytes
- Intent classification from derived audio features
- Confidence and candidate ranking with extended audio features
- Reverse text to dog-expression mapping
- Reverse parameter variation
- Analytics summary generation
- JSON repository persistence
- Local process inference JSON mapping
- Inference model selection and fallback resolution

### Widget Tests
- Reverse translation flow
- Session history rendering
- Dashboard tab presence

## 3. Manual Regression Checklist
1. Launch app on Windows.
2. Confirm forward translation screen opens.
3. Add a dog profile and select it.
4. Start and stop microphone recording.
5. Confirm waveform appears during recording.
6. Confirm analysis result appears with:
   - Japanese emotion label
   - candidate list
   - vocal type
   - context
   - valence / arousal hints
   - quality guidance
7. Apply a feedback label to the latest forward result.
8. Switch or confirm the selected microphone device.
9. Change the inference model selector and confirm the status text updates.
10. Enter Japanese text in reverse mode.
11. Change breed, age, size, and tension, then confirm output changes.
12. Confirm history panel contains persisted forward and reverse interactions.
13. Open Dashboard and confirm summary counts plus comparison cards.
14. Optional: place `dog2vec_runtime.json` and a compatible local inference script, then confirm provider label changes from heuristic to local runtime.

## 4. Validation Commands
- Working directory: repository root
- `flutter analyze`
- `flutter test`
- `flutter build windows`

## 5. Expected Results
- Tests pass without compilation errors.
- Windows build completes successfully.
- The app persists profiles and history locally.
- The app handles missing or weak audio gracefully.
- The app still works when no local Dog2vec runtime is configured.

## 6. Known Risk Areas
- Real microphone device behavior may differ by hardware.
- Heuristic interpretation is intentionally approximate.
- Local Dog2vec runtime quality depends on external data and classifier training.
- Saved forward recordings are stored locally but not yet preview-playable from the history list.

## 7. Observed Results
- `flutter analyze`: passed
- `flutter test`: passed with 13 tests
- `flutter build windows`: passed
- Release executable generated at `build/windows/x64/runner/Release/dog_translator.exe`
- Accuracy refinement verified with:
  - new feature fields covered in extractor and fixture-based tests
  - recalibrated intent inference still returning alert for strong guest-scene bark input
  - weak short input still falling back to `uncertain`
