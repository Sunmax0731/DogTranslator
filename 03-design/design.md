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

## 2. Decision Criteria
- Windows MVP implementation speed
- Future Android/iPhone reuse
- Local audio capture feasibility
- Testability of shared logic
- Packaging practicality

## 3. Chosen Stack
- Flutter

## 4. Rationale
Flutter is the best fit because it enables a single shared presentation and domain layer across Windows and later mobile targets, while keeping the MVP local and relatively lightweight.

## 5. Architecture
- Presentation layer: Flutter screens, widgets, state orchestration
- Application layer: use-case services for forward analysis and reverse expression generation
- Domain layer: heuristic interpreter, reverse translator, result models
- Platform adapter layer: microphone recording, temporary file access, Windows speech or playback integration

## 6. Main Modules
- `lib/app/`: app shell, theme, navigation
- `lib/features/translator/`: UI and state
- `lib/services/`: recording and playback abstractions
- `lib/domain/`: interpretation and reverse translation logic
- `test/`: unit and widget tests

## 7. Portability Strategy
- Keep audio recording behind a service interface.
- Keep interpretation logic pure Dart.
- Keep reverse text transformation pure Dart.
- Treat Windows-only helpers as replaceable adapters.

## 8. UI Structure
- Main screen with two tabs:
  - Dog voice -> human interpretation
  - Human text -> dog expression
- Shared history panel
- Clear explanation that outputs are experimental estimations

## 9. State Flow
1. User triggers action from UI.
2. State controller invokes recording or reverse translation service.
3. Domain logic produces a normalized result object.
4. UI renders result and appends history entry.
