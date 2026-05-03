# Accuracy Improvements Task

## Design Summary
- Preserve the existing `InferenceProvider` boundary.
- Improve the fallback heuristic path rather than coupling UI to a model runtime.
- Treat handcrafted audio features as a fast calibration layer that remains useful even when Dog2vec is unavailable.

## Applied Pattern
1. `AudioFeatureExtractor` produces a richer feature vector.
2. `DogIntentInterpreter` performs:
   - dog-vocal detection
   - vocal-type inference
   - context inference
   - raw scoring
   - consistency adjustment
   - softmax probability ranking
3. UI consumes the same `TranslationResult` contract without further changes.
