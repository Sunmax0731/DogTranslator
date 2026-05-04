# DogTranslator Requirements Definition

## 1. Product Vision
DogTranslator is a Windows-first application that records dog vocalizations, estimates likely emotional intent, and presents that interpretation as readable text. The product is positioned as an `interpretation` and `emotion estimation` tool, not a scientifically validated literal translator.

## 2. Current Product Direction
- Primary experience: dog voice -> human-readable interpretation
- Reverse mode status: implementation retained internally, but hidden from the main UI until quality improves
- Model direction: heuristic inference remains the safe fallback, while Dog2vec-backed local runtime is added as an optional higher-fidelity path

## 3. Target Users
- Dog owners who want a practical and playful interpretation tool
- Early testers interested in local audio AI
- Users who want to keep histories, compare sessions, and refine interpretation per individual dog

## 4. Priority User Scenarios
1. A user records a bark and gets a Japanese emotional interpretation such as `遊びたい`, `さみしい`, or `警戒している`.
2. A user wants to hover each result parameter and understand what it means.
3. A user wants to manage dog profiles and shared app settings from one dedicated settings surface.
4. A user wants to search past sessions, confirm when they were recorded, and replay a saved recording.
5. A user wants the app to remember an individual dog's vocal tendency and use that as a personalization signal.
6. A user wants to try Dog2vec local inference when the runtime is available, but still use the app safely when it is not.

## 5. Scope After Forward-Only UI Refresh
### In Scope
- Windows desktop application
- Microphone audio capture
- Manual start / stop recording
- Forward interpretation only in the visible UI
- Session history with local persistence, search, date display, and replay
- Tooltips for displayed interpretation parameters
- Live recording waveform
- Microphone device selection
- Dog profile registration, editing, deletion, and selection
- Shared settings tab
- Theme preset selection
- Dog-specific calibration samples from recorded forward sessions
- Candidate probability pie chart
- Feedback input via radio buttons
- Optional Dog2vec local runtime with external Python process
- Pomeranian breed support

### Out of Scope
- Scientifically validated dog-language translation
- Public cloud inference as a requirement
- Mobile shipping in the current phase
- Reverse mode as a user-facing release feature in the current UI
- Learned per-breed bark synthesis with validated datasets

## 6. Functional Requirements
1. The app must allow the user to start and stop microphone recording.
2. The app must analyze the latest recorded audio and produce:
   - a primary interpretation
   - ranked candidates
   - confidence wording
   - vocal type
   - context hint
   - valence / arousal hints
   - provider label
3. The app must show explanatory tooltips for displayed interpretation parameters.
4. The app must show a live waveform while recording.
5. The app must allow microphone device selection on Windows.
6. The app must persist profiles, forward history, settings, and feedback locally.
7. The app must offer a settings tab for:
   - theme selection
   - inference model selection
   - profile management
8. The app must still allow profile creation from the existing recording-side flow.
9. The app must allow replaying a saved forward recording from history.
10. The app must allow searching saved forward sessions.
11. The app must show session timestamps with date and time.
12. The app must allow attaching a recorded forward sample to a selected dog profile as a calibration hint.
13. The app must hide the reverse interpretation feature from the visible UI while keeping its implementation in the codebase.
14. The app must support an optional Dog2vec local runtime and fall back gracefully when it is unavailable or fails.

## 7. Non-Functional Requirements
- Responsiveness: forward results should appear within a few seconds after recording stops.
- Privacy: recordings, profiles, and histories stay local in this phase.
- Resilience: missing microphone, missing runtime, or replay failure should not crash the app.
- Maintainability: hidden reverse functionality should remain isolated enough to be restored later.
- Portability: inference runtime must stay behind a boundary that can later be replaced for mobile.
- UX quality: the Windows UI should follow a calmer, WinUI3-aligned information hierarchy rather than a hero-centric marketing layout.

## 8. Risks and Assumptions
### Risks
- Dog2vec runtime requires a large model file and Python dependencies.
- Downstream classifier quality still depends on heuristics or separately trained heads.
- User-provided calibration samples may be sparse or noisy.
- Windows audio-device behavior can still vary by hardware.

### Assumptions
- The core product remains an interpretation tool.
- Dog-specific calibration is a personalization hint, not full supervised retraining.
- Reverse mode should remain hidden until fidelity improves enough for public use.
- Dog2vec integration in this phase is local-process based, not embedded directly into Flutter.

## 9. Acceptance Criteria
- A Windows user can record audio and receive a forward interpretation.
- The visible UI contains Forward, Dashboard, and Settings flows only.
- The user can inspect parameter meanings via tooltips.
- The user can search and replay saved forward sessions from history.
- The user can manage profiles from Settings and still add them from the recording flow.
- The user can choose a theme preset and inference model in Settings.
- The user can add a calibration sample from a saved forward recording to a profile.
- The app works with or without Dog2vec local runtime configuration.

## 10. Release Packaging Requirements
- The primary Windows distribution format must be an installer rather than a raw zip-only package.
- The base installer must not require the Dog2vec weight file to be bundled inside the desktop app payload.
- The installer must provision runtime configuration automatically without requiring users to hand-edit JSON or environment settings.
- The installer must download Dog2vec runtime assets during installation.
- The uninstaller must remove installer-created runtime settings and downloaded model/runtime assets.
