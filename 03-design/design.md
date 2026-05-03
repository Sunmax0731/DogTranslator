# DogTranslator Design

## 1. Candidate Stacks
### Option A: Flutter desktop/mobile
- Pros: shared UI and core logic across Windows, Android, iPhone
- Cons: desktop audio packages vary in maturity

### Option B: WPF now, mobile later with separate app
- Pros: strong Windows integration
- Cons: poor cross-platform reuse

### Option C: Electron + web audio
- Pros: flexible UI ecosystem
- Cons: heavier runtime and less natural mobile path

## 2. Decision
- Chosen stack: Flutter
- Reason: best balance of Windows MVP delivery speed and future mobile reuse

## 3. Adopted Design Patterns
### Presentation Controller
- `HomeController` owns screen state, async flows, and persistence triggers.
- Widgets read state and invoke callbacks only.

### Widget Composition
- The home page is split into:
  - `ForwardTranslatorTab`
  - `ReverseTranslatorTab`
  - `DashboardTab`
  - `HistoryPanel`
  - `WaveformPanel`
  - `CreateProfileDialog`

### Barrel Export for Domain Models
- `lib/domain/models.dart` exports smaller files under `lib/domain/models/`.

## 4. Layered Architecture
- Presentation layer:
  - Flutter pages and widgets
- Application layer:
  - `HomeController`
- Domain layer:
  - feature extraction
  - inference provider contract
  - heuristic forward interpreter
  - reverse translator
  - analytics summarizer
- Service / adapter layer:
  - recording service
  - persistence repository
  - playback service
  - local process inference bridge

## 5. Dog2vec Integration Options
### Option A: direct Dog2vec runtime inside Flutter app
- Pros: one process
- Cons: heavy dependency footprint, difficult Windows packaging, poor mobile path

### Option B: local Python / model process bridge
- Pros: pragmatic for Windows, keeps Flutter app light, allows external model updates
- Cons: requires external runtime setup

### Option C: cloud inference service
- Pros: easiest client
- Cons: privacy, cost, offline loss

### Chosen Option
- Option B

## 6. Inference Architecture
- `InferenceProvider` is async and supports raw audio bytes.
- Default path:
  - `DogIntentInterpreter`
- Optional enriched path:
  - `LocalProcessInferenceProvider`
- Resilience wrapper:
  - `ResilientInferenceProvider`
- Startup selection:
  - `InferenceProviderFactory`

## 7. Forward Pipeline Shape
1. Record WAV
2. Extract lightweight features
3. Run dog-vocal gate
4. Run provider
5. Produce:
   - intent
   - vocal type
   - context
   - valence
   - arousal
   - confidence
   - explanation

## 7A. Accuracy Refinement Strategy
- Keep the fast local heuristic path, but enrich the front-end feature vector with:
  - crest factor
  - activity ratio
  - estimated pitch
- Use a two-step decision path:
  1. compute raw intent scores
  2. apply vocal-type and context consistency adjustments
- Convert adjusted scores to probabilities with softmax so candidate ranking and confidence are less brittle than raw threshold ordering.
- Treat `DogIntentInterpreter` as the calibration layer that can later coexist with Dog2vec embeddings from the external runtime.

## 8. Local Runtime Boundary
- Flutter app does not own Dog2vec weights by default.
- External local runtime may own:
  - Dog2vec feature extraction
  - downstream classifier heads
  - JSON response generation
- Flutter maps JSON into internal `TranslationResult`.

## 9. Config Strategy
- The app looks for an optional `dog2vec_runtime.json`.
- If absent, it stays on heuristic inference.
- If present and valid, it launches the configured local command.
- User selection is persisted separately from runtime availability so the controller can resolve:
  - requested model
  - effective active model
  - human-readable fallback status

## 10. State Ownership
- `HomeController` owns:
  - selected inference model
  - effective active inference model
  - inference runtime status message
  - active profile
  - active scene mode
  - selected microphone
  - reverse preset selections
  - waveform buffer
  - current forward / reverse results
  - saved history
  - dashboard comparison selection

## 11. Persistence Strategy
- Store app state in local JSON under app-support directory.
- Persist:
  - profiles
  - forward entries
  - reverse entries
  - selected settings

## 12. Mobile Readiness
- Keep inference behind a contract so local process can later be replaced by ONNX / Sentis / TFLite compatible execution.
- Avoid desktop-only coupling in UI state flow.
