# DogTranslator Specification

## 1. Feature Set
- Forward mode: microphone audio -> staged analysis -> ranked interpretation candidates
- Reverse mode: human text -> emotion style estimation -> dog-style expressive output
- Session history: persistent local history for recent interactions
- Live waveform / level trace during recording
- Input microphone selection for Windows
- Inference model selection between auto, heuristic, and Dog2vec-local preference
- Dog profile selection and persistence
- Scene tagging
- Dashboard summaries
- Optional local process inference bridge for Dog2vec-style runtime

## 2. Forward Mode Behavior
### Input
- The user starts recording manually.
- The user stops recording manually.
- The user can choose a microphone input before recording.
- The user can choose the inference model policy before recording.
- The user can optionally choose a dog profile and scene mode before recording.

### Analysis Pipeline
1. Load recorded PCM audio.
2. Compute duration, RMS, peak level, zero-crossing rate, dynamic range, spectral centroid, high-band ratio, crest factor, activity ratio, and estimated pitch.
3. Generate recording-quality hints.
4. Run dog-vocal detection gate.
5. Run the active inference provider.
6. Produce:
   - primary interpretation
   - ranked candidate list
   - vocal type
   - context hint
   - valence / arousal
   - explanation
   - confidence
   - provider label

### Output
- Primary intent label
- Japanese emotional label
- Explanation sentence
- Confidence: `high`, `medium`, or `low`
- Ranked candidates
- Vocal type
- Context hint
- Valence / arousal hint values
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

## 4. Additional Forward Classification Axes
### Vocal Types
- `bark`
- `growl`
- `whine`
- `howl`
- `yelp`
- `pant`
- `mixed`
- `unknown`

### Context Hints
- `stranger_or_noise`
- `owner_return`
- `food_or_attention`
- `walk_anticipation`
- `play`
- `alone`
- `other_dog`
- `conflict`
- `unknown`

## 5. Multiple Candidate Rules
- The app should display up to 3 ranked candidates.
- The top candidate becomes the primary label.
- Close-scoring candidates should remain visible instead of being discarded.

## 6. Recording Visualization and Quality
- While recording is active, the app should show a live waveform or bar-trace style meter.
- The visualization should reset when a new recording session starts.
- Quality hints may include:
  - recording too short
  - level too weak
  - peak too spiky
  - likely noisy / unstable input

## 7. Profiles and Scene Modes
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

## 8. Reverse Mode Behavior
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

## 9. Local Process Inference Contract
### Invocation
- The app loads optional runtime config from JSON.
- It launches the configured command with its configured args.
- It appends `--input <wavPath>` to the invocation.

### Expected stdout JSON
```json
{
  "detected": true,
  "vocal_type": "bark",
  "emotion": { "top": "alert", "score": 0.74 },
  "context": { "top": "stranger_or_noise", "score": 0.62 },
  "valence": -0.22,
  "arousal": 0.81,
  "confidence": 0.68,
  "message": "来客や物音に反応して警戒している可能性があります。"
}
```

### Fallback Rules
- No config: use heuristic provider.
- Process failure: use heuristic provider.
- Weak or likely non-dog input: return uncertain with guidance.

### Model Selection Rules
- `auto`: prefer Dog2vec local runtime when configured, otherwise heuristic.
- `heuristic`: always use the in-app heuristic pipeline.
- `dog2vec_local`: prefer the local Dog2vec runtime; if unavailable, fall back to heuristic and surface that fallback in UI status text.

## 9A. Accuracy Improvement Rules
- Heuristic forward scoring should combine classic amplitude features with activity and pitch-related features.
- Candidate probabilities should be normalized from calibrated scores instead of using raw rule totals directly.
- Vocal-type and context estimates should feed back into final intent ranking as consistency adjustments.
- Weak, noisy, or clearly non-dog-like pitch ranges should reduce confidence and may force `uncertain`.
- Japanese output labels and explanations must remain human-readable and avoid mojibake.

## 10. History and Comparison
- The app should persist forward and reverse interactions locally.
- The app should allow selecting recent forward results for side-by-side comparison.
- Saved forward results should keep:
  - timestamp
  - features
  - primary label
  - candidate labels
  - profile id
  - scene mode
  - vocal type
  - context
  - valence / arousal
  - quality hints
  - manual feedback label

## 11. Analytics Dashboard
- Total saved interactions
- Forward intent counts
- Scene distribution
- Profile distribution
- Manual feedback coverage

## 12. Error Handling
- No microphone available: show device guidance and disable recording action.
- Recording too short: return low-confidence output plus quality hint.
- File parse failure: show analysis error and keep the session alive.
- Unsupported reverse input: fall back to neutral output.
- Playback failure: keep the reverse result visible and show failure without blocking the UI.
- Selected microphone unavailable: fall back to default input and show a message.
- Persistence read failure: reset to empty local state and show a warning.
- Local inference process failure: fall back to heuristic inference without crashing.

## 13. Acceptance Scenarios
1. User records a short loud bark -> app returns ranked alert/greeting candidates with quality guidance.
2. User records a soft long sound -> app returns anxious or sleepy candidates.
3. User records near silence -> app returns uncertain with low confidence.
4. User changes the microphone device and records successfully from the selected input.
5. User saves multiple forward results and compares them side-by-side.
6. User registers a dog profile and reuses it for later recordings.
7. User enters reverse text, changes breed / age / size / tension, and hears different synthetic output.
8. User opens the dashboard and sees persisted statistics.
9. Local Dog2vec-style runtime returns JSON -> app maps it into the forward result structure.
