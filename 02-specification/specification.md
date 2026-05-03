# DogTranslator Specification

## 1. Feature Set
- Forward mode: microphone audio -> analysis -> ranked interpretation candidates
- Reverse mode: human text -> emotion style estimation -> dog-style expressive output
- Session history: persistent local history for recent interactions
- Live waveform / level trace during recording
- Input microphone selection for Windows
- Dog profile selection and persistence
- Scene tagging
- Dashboard summaries

## 2. Forward Mode Behavior
### Input
- The user starts recording manually.
- The user stops recording manually.
- The user can choose a microphone input before recording.
- The user can optionally choose a dog profile and scene mode before recording.

### Analysis Pipeline
1. Load recorded PCM audio.
2. Compute duration, RMS, peak level, zero-crossing rate, dynamic range, spectral centroid, and high-band ratio.
3. Generate recording-quality hints.
4. Run the active inference provider.
5. Produce:
   - primary interpretation
   - ranked candidate list
   - quality guidance
   - explanation
   - confidence

### Output
- Primary intent label
- Japanese emotional label
- Explanation sentence
- Confidence: `high`, `medium`, or `low`
- Ranked candidates
- Feature summary for debugging
- Quality hints

## 3. Forward Emotion Categories
- `excited_greeting`
- `attention_seeking`
- `warning_alert`
- `anxious_whine`
- `sleepy`
- `restless_energy`
- `happy_relaxed`
- `bored`
- `uncertain`

## 4. Multiple Candidate Rules
- The app should display up to 3 ranked candidates.
- The top candidate becomes the primary label.
- Close-scoring candidates should remain visible instead of being discarded.

## 5. Recording Visualization and Quality
- While recording is active, the app should show a live waveform or bar-trace style meter.
- The visualization should reset when a new recording session starts.
- Quality hints may include:
  - recording too short
  - level too weak
  - peak too spiky
  - likely noisy / unstable input

## 6. Profiles and Scene Modes
### Dog Profile Fields
- profile id
- display name
- breed
- age stage
- size class
- notes

### Scene Modes
- home / normal
- playtime
- mealtime
- walk
- guest / visitor
- night / rest

## 7. Reverse Mode Behavior
### Input
- Free-text Japanese or English message
- Breed
- Age stage
- Size class
- Tension level
- Optional active dog profile

### Transformation
1. Detect simple emotional cues in text.
2. Resolve bark style profile from breed / age / size / tension.
3. Produce:
   - dog-style text
   - emotion tag
   - descriptive explanation
   - playback audio

### Output
- Dog-style expressive string
- Emotion tag
- Selected preset summary
- Playback availability state

## 8. History and Comparison
- The app should persist forward and reverse interactions locally.
- The app should allow selecting recent forward results for side-by-side comparison.
- Saved forward results should keep:
  - timestamp
  - features
  - primary label
  - candidate labels
  - profile id
  - scene mode
  - quality hints
  - manual feedback label

## 9. Analytics Dashboard
- Total saved interactions
- Forward intent counts
- Scene distribution
- Profile distribution
- Manual feedback coverage
- Hour-of-day activity summary

## 10. Inference Abstraction
- The active inference engine must be behind an interface.
- The current implementation remains heuristic.
- Future engines may include local ONNX / TFLite or cloud inference without breaking the UI contract.

## 11. Error Handling
- No microphone available: show device guidance and disable recording action.
- Recording too short: return low-confidence output plus quality hint.
- File parse failure: show analysis error and keep the session alive.
- Unsupported reverse input: fall back to neutral output.
- Playback failure: keep the reverse result visible and show failure without blocking the UI.
- Selected microphone unavailable: fall back to default input and show a message.
- Persistence read failure: reset to empty local state and show a warning.

## 12. Acceptance Scenarios
1. User records a short loud bark -> app returns ranked alert/greeting candidates with quality guidance.
2. User records a soft long sound -> app returns anxious or sleepy candidates.
3. User records near silence -> app returns uncertain with low confidence.
4. User changes the microphone device and records successfully from the selected input.
5. User saves multiple forward results and compares them side-by-side.
6. User registers a dog profile and reuses it for later recordings.
7. User enters reverse text, changes breed / age / size / tension, and hears different synthetic output.
8. User opens the dashboard and sees persisted statistics.
