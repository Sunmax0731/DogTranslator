# DogTranslator Specification

## 1. Feature Set
- Forward mode: microphone audio -> staged analysis -> ranked interpretation candidates
- Dashboard: local summaries and comparison support
- Settings: global app preferences and profile management
- Session history: persistent local forward history with search and replay
- Live waveform / level trace during recording
- Input microphone selection for Windows
- Inference model selection between auto, heuristic, and Dog2vec-local preference
- Optional Dog2vec local runtime via Python process
- Hidden reverse implementation retained in codebase, but not surfaced in the release UI

## 2. Visible Navigation
- Wide layout:
  - left navigation card
  - main content
  - right-side history panel
- Narrow layout:
  - bottom navigation
  - stacked history section
- Visible destinations:
  - `Forward`
  - `Dashboard`
  - `Settings`

## 3. Forward Mode Behavior
### Input
- The user starts recording manually.
- The user stops recording manually.
- The user can choose a microphone input before recording.
- The user can optionally choose a dog profile and scene mode before recording.

### Analysis Pipeline
1. Load recorded PCM audio.
2. Compute duration, RMS, peak level, zero-crossing rate, dynamic range, spectral centroid, high-band ratio, crest factor, activity ratio, and estimated pitch.
3. Generate recording-quality hints.
4. Run dog-vocal detection gate.
5. Run the active inference provider.
6. Apply profile-calibration similarity when a selected profile has voice calibration data.
7. Produce:
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
- Candidate pie chart
- Vocal type
- Context hint
- Valence / arousal hint values
- Feature summary
- Quality hints

## 4. Result Parameter Help
- Hovering result chips should show tooltips for:
  - confidence
  - provider
  - vocal type
  - context
  - duration
  - RMS
  - peak
  - pitch
  - valence
  - arousal

## 5. Forward Emotion Categories
- `excited_greeting`
- `attention_seeking`
- `warning_alert`
- `anxious_whine`
- `sleepy`
- `restless_energy`
- `happy_relaxed`
- `bored`
- `uncertain`

## 6. Additional Forward Classification Axes
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

## 7. Recording Visualization and Quality
- While recording is active, the app should show a live waveform or bar-trace style meter.
- The visualization should reset when a new recording session starts.
- Quality hints may include:
  - recording too short
  - level too weak
  - peak too spiky
  - likely noisy / unstable input

## 8. Profiles and Calibration
### Dog Profile Fields
- profile id
- display name
- breed
- age stage
- size class
- notes
- optional voice calibration aggregate:
  - sample count
  - average pitch
  - average RMS
  - average activity ratio
  - last calibration timestamp

### Calibration Rule
- The user can add the latest saved forward recording as a calibration sample for a profile.
- Calibration updates aggregate statistics only in this phase.
- Calibration influences heuristic scoring as a personalization bias, not as full retraining.

### Supported Breeds
- include existing breeds plus `Pomeranian`

## 9. Feedback Input
- Saved forward records can store a manual feedback label.
- The visible input control should use radio buttons, not a dropdown.

## 10. Settings Tab Behavior
### Common Settings
- Theme preset selection:
  - default
  - ocean
  - sunset
  - forest
  - graphite
- Inference model selection:
  - `auto`
  - `heuristic`
  - `dog2vec_local`

### Profile Management
- Add profile
- Edit profile
- Delete profile
- Add latest recording as calibration sample

## 11. Session History
- Persist forward and reverse interactions locally, but the visible history panel should focus on forward sessions.
- History panel behavior:
  - search box
  - date + time display
  - replay saved forward recording
  - compare selection toggle
- Visible metadata:
  - timestamp
  - profile name
  - scene mode
  - primary interpretation
  - short explanation

## 12. Dashboard
- Total forward sessions
- Feedback coverage
- Profile count
- Comparison summary for selected forward records

## 13. Local Process Inference Contract
### Invocation
- The app loads optional runtime config from JSON.
- It launches the configured command with its configured args.
- It appends `--input <wavPath>` to the invocation.

### Runtime Files
- `dog2vec_runtime.json` at repo root or deployed working directory
- `dog_voice_local/` runtime folder
- optional upstream helper repo under `dog_voice_local/vendor/dog2vec`
- optional weight file under `dog_voice_local/models/dog2vec/dog2vec_130k_9.pt`

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
  "message": "警戒に近い鳴き方として解釈しました。"
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

## 14. Hidden Reverse Feature Rule
- Reverse implementation remains in source control.
- The release UI must not expose:
  - reverse tab
  - reverse history view
  - reverse dashboard emphasis
- Future reactivation should require UI wiring only, not full reimplementation.

## 15. Error Handling
- No microphone available: show device guidance and disable recording action.
- Recording too short: return low-confidence output plus quality hint.
- File parse failure: show analysis error and keep the session alive.
- Playback failure: keep the result visible and show failure without blocking the UI.
- Selected microphone unavailable: fall back to default input and show a message.
- Persistence read failure: reset to empty local state and show a warning.
- Local inference process failure: fall back to heuristic inference without crashing.

## 16. Acceptance Scenarios
1. User records a short loud bark -> app returns ranked alert/greeting candidates with quality guidance.
2. User records near silence -> app returns uncertain with low confidence.
3. User hovers a feature chip -> app shows a tooltip explaining the parameter.
4. User changes the microphone device and records successfully from the selected input.
5. User opens Settings and changes the theme preset.
6. User adds, edits, and deletes profiles from Settings.
7. User replays a saved forward recording from history.
8. User searches history and sees date + time on results.
9. User adds the latest forward recording as a calibration sample for a profile.
10. Local Dog2vec runtime returns JSON -> app maps it into the forward result structure.
11. Reverse implementation remains present in code, but the release UI shows only Forward, Dashboard, and Settings.

## 17. Installer and Runtime Bootstrap Behavior
### Install
- Install target: `%LocalAppData%\\Programs\\DogTranslator`
- Post-install bootstrap target:
  - runtime root: `%LocalAppData%\\DogTranslator\\dog2vec-runtime`
  - config root: `%LocalAppData%\\DogTranslator\\.dog2vec`
- Installer bootstrap downloads:
  - embedded Python runtime
  - Python dependencies for Dog2vec local inference
  - Dog2vec helper source archive
  - Dog2vec model weight file
- Installer bootstrap writes runtime JSON and user environment variables automatically.

### Uninstall
- Uninstall removes:
  - runtime root
  - config root
  - `DOG_TRANSLATOR_RUNTIME_ROOT`
  - `DOG_TRANSLATOR_RUNTIME_CONFIG`
