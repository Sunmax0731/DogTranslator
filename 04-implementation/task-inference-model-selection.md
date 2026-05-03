# Inference Model Selection Task

## Completed Work
- Added persisted `selectedInferenceModel` setting.
- Refactored startup and screen wiring to use `InferenceProviderFactory` instead of a single fixed provider.
- Added UI for selecting `auto`, `heuristic`, and `Dog2vec ローカル`.
- Added runtime-aware status messaging for requested-vs-active model resolution.

## Validation
- `flutter analyze`
- `flutter test`
- `flutter build windows`
