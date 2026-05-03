# DogTranslator Specification

## 1. Feature Set
- Forward mode: microphone audio -> analysis -> interpretation label and explanation
- Reverse mode: human text -> emotion style estimation -> dog-style expressive output
- Session history: recent forward and reverse interactions
- Live waveform/level trace during recording
- Input microphone selection for Windows

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
- Japanese emotional label
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

## 3.1 Forward Label Mapping
- `excited_greeting` -> `遊びたい`
- `attention_seeking` -> `かまってほしい`
- `warning_alert` -> `警戒している`
- `anxious_whine` -> `さみしい / 甘えたい`
- `restless_energy` -> `落ち着かない`
- `uncertain` -> `判断が難しい`

## 3.2 Recording Visualization
- While recording is active, the app should show a live waveform or bar-trace style meter.
- A lightweight amplitude trace is acceptable for the current release candidate.
- The visualization should reset when a new recording session starts.

## 3.3 Microphone Selection
- The app should list available Windows input devices.
- The user should be able to select one active device before recording.
- If a selected device disappears, the app should fall back to the default input and show a message.

## 4. Reverse Mode Behavior
### Input
- Free-text Japanese or English message
- Optional emotion style override
- Future expansion: optional breed selection

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

## 4.1 Reverse Expansion Boundary
### Current release-candidate target
- Better rule-based phrasing and more stable playback

### Deferred expansion target
- breed-specific bark presets
- richer waveform or sample-based bark assets
- model-backed dog-voice rendering

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
- Playback timeout: keep the reverse result visible and show playback failure without blocking the UI.
- Selected microphone unavailable: show fallback or recovery guidance.

## 7. Acceptance Scenarios
1. User records a short loud bark -> app returns `warning_alert` or `excited_greeting` with explanation.
2. User records a softer longer sound -> app returns `anxious_whine` or `attention_seeking`.
3. User submits "こっちに来て" -> app returns a playful dog-style output with a friendly emotion tag.
4. User records near silence -> app returns `uncertain` with low confidence.
5. User changes the microphone device and records successfully from the selected input.
6. User sees a live recording waveform while recording is active.
