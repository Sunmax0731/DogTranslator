# Inference Model Selection Task

## Coverage
- Added factory tests for:
  - auto -> heuristic fallback without local runtime
  - Dog2vec-local activation with runtime config
- Existing widget and build validation confirm the app still launches and functions with the new selection flow.

## Result
- `flutter analyze`: passed
- `flutter test`: passed
- `flutter build windows`: passed
