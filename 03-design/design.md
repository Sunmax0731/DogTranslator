# DogTranslator Design

## 1. Candidate UX Directions
### Option A: Hero-led multi-mode landing layout
- Pros: strong first impression
- Cons: wastes vertical space and over-emphasizes the hidden reverse feature

### Option B: WinUI3-style utility workspace
- Pros: calmer hierarchy, better for repeated use, closer to Windows app conventions
- Cons: less promotional

### Option C: Dense analytics-first console
- Pros: strong for power users
- Cons: intimidating for casual users

## 2. UX Decision
- Chosen direction: Option B
- Reason: the app is now a forward-focused utility, so it benefits more from a practical Windows workspace than a hero-first landing surface.

## 3. Adopted Design Patterns
### Presentation Controller
- `HomeController` owns screen state, async flows, persistence triggers, and runtime resolution.

### Widget Composition
- Home UI is split into focused widgets:
  - `ForwardTranslatorTab`
  - `DashboardTab`
  - `SettingsTab`
  - `HistoryPanel`
  - `WaveformPanel`
  - `CreateProfileDialog`
  - `CandidatePieChart`

### Hidden Feature Preservation
- Reverse-mode widgets and services remain compiled and reusable, but routing does not expose them.

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

## 5. WinUI3-Oriented UI Structure
- Remove the hero banner.
- Use surface-separated cards with quiet contrast and rounded corners.
- Keep navigation persistent and explicit.
- Keep key actions near the data they affect.
- Reserve accent color for action and state, not large decorative regions.
- Move configuration into a dedicated Settings surface.

## 6. Navigation Design
### Wide Layout
- left navigation rail card
- center content card stack
- right session history card

### Narrow Layout
- bottom `NavigationBar`
- content first, history later in the scroll

### Visible Pages
- Forward
- Dashboard
- Settings

## 7. Inference Architecture
- `InferenceProvider` stays async and raw-audio aware.
- Default path:
  - `DogIntentInterpreter`
- Optional enriched path:
  - `LocalProcessInferenceProvider`
- Resilience wrapper:
  - `ResilientInferenceProvider`
- Startup selection:
  - `InferenceProviderFactory`

## 8. Dog2vec Integration Strategy
### Option A: direct Dog2vec runtime inside Flutter app
- Pros: single process
- Cons: large footprint and difficult packaging

### Option B: local Python / model process bridge
- Pros: pragmatic for Windows, keeps Flutter app light, aligns with the provided design memo
- Cons: requires external dependencies and model assets

### Option C: cloud inference service
- Pros: thin client
- Cons: privacy and offline tradeoffs

### Chosen Option
- Option B

## 9. Local Runtime Boundary
- Flutter does not bundle Dog2vec weights inside app code.
- Runtime assets live under `dog_voice_local/`.
- Config lives in `dog2vec_runtime.json`.
- Runtime may operate in:
  - bootstrap heuristic mode
  - Dog2vec-enhanced embedding mode
- Flutter only consumes normalized JSON output.

## 10. Personalization Design
- Dog-specific calibration is modeled as aggregate profile statistics:
  - average pitch
  - average RMS
  - average activity ratio
  - sample count
- `DogIntentInterpreter` uses similarity to the active profile calibration as a small scoring bias.
- This keeps personalization cheap and local while avoiding live retraining complexity.

## 11. State Ownership
- `HomeController` owns:
  - selected inference model
  - effective active inference model
  - inference runtime status message
  - selected theme preset
  - active profile
  - active scene mode
  - selected microphone
  - waveform buffer
  - current forward result
  - saved history
  - dashboard comparison selection

## 12. History Interaction Design
- History focuses on forward records in the visible UI.
- Each item is clickable and replayable.
- Search is local, client-side, and lightweight.
- Date + time are shown to support longer-lived usage.

## 13. Settings Design
- Common settings and profile management are grouped together intentionally.
- Existing add-profile flow from recording remains as a convenience shortcut.
- Settings should not be a dumping ground; only app-wide or durable profile actions belong there.

## 14. Mobile Readiness
- Hidden reverse code remains isolated and can be restored later.
- Inference stays behind a contract so Python runtime can later be replaced by ONNX / Sentis / TFLite compatible execution.
- UI state flow avoids tight coupling to desktop-only navigation patterns.
