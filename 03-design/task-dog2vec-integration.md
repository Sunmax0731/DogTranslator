# Dog2vec Integration Design Task

## Chosen Pattern
- Async `InferenceProvider`
- Optional `LocalProcessInferenceProvider`
- `ResilientInferenceProvider` fallback wrapper
- `InferenceProviderFactory` for startup selection

## Boundary
- Flutter app does not own Dog2vec weights.
- External local runtime owns:
  - Dog2vec feature extraction
  - downstream classifier heads
  - JSON result emission
- Flutter app owns:
  - recording
  - lightweight features
  - fallback heuristic inference
  - result rendering
  - persistence

## Main Tradeoff
- Chosen: local process bridge
- Not chosen: direct PyTorch embedding in Flutter desktop app
- Reason:
  - smaller Flutter surface
  - safer deployment
  - future ONNX or service migration path
