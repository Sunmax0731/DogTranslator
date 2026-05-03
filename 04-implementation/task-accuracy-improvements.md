# Accuracy Improvements Task

## Completed Work
- Added `crestFactor`, `activityRatio`, and `pitchHz` to `AudioFeatures`.
- Extended `AudioFeatureExtractor` to compute the new metrics.
- Rebuilt `DogIntentInterpreter` with:
  - stronger dog-vocal gating
  - refined vocal-type inference
  - context-aware score adjustments
  - softmax-ranked candidates
  - cleaner confidence calibration
- Repaired Japanese enum labels and explanation text.

## Validation
- `flutter analyze`
- `flutter test`
- `flutter build windows`
