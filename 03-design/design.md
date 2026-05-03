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

## 3. Architecture
- Presentation layer: Flutter screens, widgets, state orchestration
- Application layer: controllers / repositories for forward analysis, reverse generation, persistence
- Domain layer: audio feature extraction, inference provider, reverse translator, analytics summarizer
- Platform adapter layer: recording, local file access, Windows playback integration

## 4. New Modules for MVP+
- `lib/domain/inference_provider.dart`
- `lib/domain/heuristic_inference_provider.dart`
- `lib/domain/analytics_service.dart`
- `lib/services/local_app_repository.dart`
- `lib/services/app_storage_service.dart`

## 5. State Additions
- Active dog profile
- Active scene mode
- Saved history list
- Compare selection state
- Dashboard metrics
- Forward feedback label

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
  - profile
  - scene
  - feature chips
  - candidate list

## 10. Dashboard Design
- Summary chips
- Bar-list style counts by emotion and scene
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
