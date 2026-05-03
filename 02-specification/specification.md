# DogTranslator Specification

## 1. Feature Set
- Forward mode: microphone audio -> analysis -> interpretation label and explanation
- Reverse mode: human text -> emotion style estimation -> dog-style expressive output
- Session history: recent forward and reverse interactions

## 2. Forward Mode Behavior
### Input
- The user starts recording manually.
- The user stops recording manually.
- A recorded WAV file becomes the analysis input.

### Analysis Pipeline
1. Load recorded PCM audio.
2. Compute duration, RMS energy, peak level, and zero-crossing proxy.
3. Map features to an intent category using heuristic rules.
4. Generate a natural-language explanation and qualitative confidence.

### Output
- Intent label
- Explanation sentence
- Confidence: `high`, `medium`, or `low`
- Feature summary for debugging

## 3. Heuristic Intent Categories
- `excited_greeting`
- `attention_seeking`
- `warning_alert`
- `anxious_whine`
- `restless_energy`
- `uncertain`

## 4. Reverse Mode Behavior
### Input
- Free-text Japanese or English message
- Optional emotion style override

### Transformation
1. Detect simple emotional cues in text.
2. Select a bark style pattern.
3. Produce:
   - dog-style text such as `wan! wan!` / `woof-ruff!`
   - descriptive intent text
   - optional playback cue

### Output
- Dog-style expressive string
- Emotion tag
- Playback availability state

## 5. Option Comparison
### Option A: rule-based heuristic MVP
- Pros: local, fast, immediately testable, low dependency risk
- Cons: low scientific fidelity

### Option B: pretrained audio classifier
- Pros: potentially better signal handling
- Cons: model sourcing, integration, and validation overhead

### Option C: cloud AI inference
- Pros: easier model iteration
- Cons: privacy risk, cost, network dependency

### Chosen Option
- Option A for MVP

### Why
- The project needs a working Windows-first MVP with clean future interfaces, and there is no validated literal translation model ready for immediate integration.

## 6. Error Handling
- No microphone available: show device guidance and disable recording action.
- Recording too short: return a low-confidence result with explanation.
- File parse failure: show analysis error and keep the session alive.
- Unsupported reverse input: fall back to neutral playful bark output.

## 7. Acceptance Scenarios
1. User records a short loud bark -> app returns `warning_alert` or `excited_greeting` with explanation.
2. User records a softer longer sound -> app returns `anxious_whine` or `attention_seeking`.
3. User submits "こっちに来て" -> app returns a playful dog-style output with a friendly emotion tag.
4. User records near silence -> app returns `uncertain` with low confidence.
