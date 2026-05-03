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
- Reason:
  - keeps side effects out of widget build methods
  - makes the page easier to test and refactor
  - allows future split into additional controllers per tab

### Widget Composition
- The former monolithic home page is split into:
  - `ForwardTranslatorTab`
  - `ReverseTranslatorTab`
  - `DashboardTab`
  - `HistoryPanel`
  - `WaveformPanel`
  - `CreateProfileDialog`
- Reason:
  - each file maps to one visible responsibility
  - UI changes stay localized
  - long build methods are avoided

### Barrel Export for Domain Models
- `lib/domain/models.dart` now exports smaller files under `lib/domain/models/`.
- Model responsibilities are separated into:
  - enums and labels
  - audio features
  - translation models
  - profile models
  - history models
  - app state models
  - analytics summary
- Reason:
  - keeps import surface stable
  - reduces single-file growth
  - makes future domain expansion manageable

## 4. Layered Architecture
- Presentation layer:
  - Flutter pages and widgets
  - view-only rendering logic
- Application layer:
  - `HomeController`
  - orchestration of recording, inference, persistence, playback
- Domain layer:
  - audio feature extraction
  - inference provider
  - reverse translator
  - analytics summarizer
  - domain models
- Platform adapter layer:
  - recording service
  - local file persistence
  - Windows playback integration

## 5. State Ownership
- `HomeController` owns:
  - active profile
  - active scene mode
  - selected microphone
  - reverse preset selections
  - waveform buffer
  - current forward/reverse results
  - saved history
  - dashboard comparison selection
- Widgets do not mutate shared state directly.

## 6. Persistence Strategy
- Store app state in local JSON under app-support directory.
- Persist:
  - profiles
  - saved forward entries
  - saved reverse entries
  - selected settings
- Keep repository interface small so later DB migration is possible.

## 7. Inference Strategy
### Option A: heuristic interpreter only
- Pros: simple, current implementation
- Cons: hard to swap later

### Option B: provider interface with heuristic provider now
- Pros: future-ready, low risk
- Cons: slightly more plumbing now

### Chosen Option
- Option B

## 8. UI Structure
- Main tab set:
  - Forward
  - Reverse
  - Dashboard
- Shared right-side panel on wide screens:
  - saved history
  - compare quick actions
- Narrow screens keep vertical stacking for mobile readiness.

## 9. Comparison Design
- User can mark up to 2 saved forward entries for comparison.
- Compare card shows:
  - timestamp
  - primary label
  - confidence
  - scene
  - feature chips
  - candidate list

## 10. Dashboard Design
- Summary chips
- Count lists by emotion and scene
- Feedback summary
- Recent activity list

## 11. Reverse Preset Design
- Breed drives base bark profile
- Age stage alters pitch and duration bias
- Size alters amplitude and low / high emphasis
- Tension alters pacing and burst density

## 12. Mobile Readiness
- Avoid fixed desktop-only widths in primary flows
- Keep cards and forms stackable
- Avoid coupling side panel content to desktop-only interaction
