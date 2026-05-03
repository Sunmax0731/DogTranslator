# Dog2vec Integration Requirements Task

## Goal
Define how a Dog2vec-oriented local inference pipeline fits the current Windows-first app.

## Decisions
- Keep the product framed as `interpretation`, not literal translation.
- Add support for a local model pipeline without making cloud access mandatory.
- Treat Dog2vec as a feature extractor plus downstream classifiers, not as a direct text generator.

## Requirement Additions
- Forward inference must support raw-audio-aware providers in addition to heuristic feature-only providers.
- The app must remain usable when the local model runtime is missing or fails.
- Forward output should include:
  - vocal type
  - inferred context
  - valence / arousal hints
  - provider label
- The app should accept a local process JSON response contract for external inference.

## Constraints
- Windows release must still work offline.
- Dog2vec weights are too large to bundle by default in the Flutter app.
- Python / PyTorch runtime remains optional and external in this phase.
