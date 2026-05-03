# Dog2vec Integration Test Task

## Automated Coverage
- Heuristic interpreter:
  - alert mapping
  - low-energy mapping
  - weak-input fallback
- Local process provider:
  - JSON response mapping into app model
- Widget flow:
  - reverse flow still works after inference contract change

## Validation Commands
- `flutter analyze`
- `flutter test`
- `flutter build windows`

## Expected Result
- App builds without requiring a Dog2vec runtime.
- If runtime config is missing, heuristic inference still works.
- If runtime is later configured, JSON contract can populate richer forward output.
