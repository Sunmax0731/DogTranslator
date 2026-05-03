# Accuracy Improvements Task

## Goal
Raise forward interpretation quality before a full external Dog2vec runtime is attached.

## Specification Decisions
- Extend local WAV analysis with `crestFactor`, `activityRatio`, and `pitchHz`.
- Use calibrated candidate probabilities instead of exposing raw heuristic scores.
- Feed vocal-type and context estimates back into final intent ranking.
- Keep weak or noisy input paths biased toward `uncertain`.

## Acceptance
- Extended features are part of the internal analysis result.
- Forward candidate ranking remains stable under existing tests.
- Japanese labels and explanations are readable in app output.
