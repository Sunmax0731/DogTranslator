# DogTranslator Requirements Definition

## 1. Product Vision
DogTranslator is a Windows-first application that listens to dog vocalizations, estimates likely emotional intent, and presents that interpretation as user-readable text. The product also explores a reverse mode where human text is transformed into dog-like expressive output for playful interaction.

## 2. Positioning
- Primary position: companion/entertainment plus behavioral hinting tool
- Explicitly not: scientifically validated literal language translation
- Recommended wording: "interpretation", "emotion estimation", "intent hint"

## 3. Target Users
- Dog owners who want a playful interpretation of their dog's vocal state
- Families and children who want an interactive pet communication experience
- Early testers interested in audio AI and animal-interaction experiments

## 4. User Scenarios
1. A user records a short bark and receives an on-screen interpretation such as "attention seeking" or "excited greeting".
2. A user records repeated whining and receives a calmer interpretation such as "anxious" or "needs reassurance".
3. A user types a short human message and asks the app to render a dog-style expressive response.
4. A user reviews recent translations to compare multiple recordings.

## 5. MVP Scope
### In Scope
- Windows desktop application
- Microphone audio capture
- Short-session audio recording and stop control
- Heuristic interpretation of recorded dog vocalizations
- Display of translated/estimated text on screen
- Experimental reverse mode: human text to dog-style expression output
- Local history of the current session
- Japanese emotional interpretation labels for forward mode in the extended pre-release scope
- Optional microphone device selection in the extended pre-release scope
- Live recording waveform in the extended pre-release scope

### Out of Scope
- Scientifically validated dog-language translation
- Veterinary diagnosis or behavioral treatment advice
- Cloud-hosted model service
- Multi-user sync
- Android and iPhone releases
- Breed-specific or dog-specific personalization in the initial release candidate
- High-fidelity learned dog-voice synthesis in the initial release candidate

## 6. Functional Requirements
1. The app must allow the user to start and stop microphone recording.
2. The app must analyze the latest recorded audio and produce an interpretation label and a natural-language explanation.
3. The app must show confidence as qualitative text, not false precision.
4. The app must allow the user to enter Japanese or English text in reverse mode.
5. The reverse mode must produce a dog-style expressive output that can be played or visually represented.
6. The app must preserve a session history of recent interactions.
7. The app must expose when a result is experimental or low-confidence.
8. The app should allow the user to choose the microphone input device on Windows.
9. The app should show a simple live waveform or level trace while recording.
10. The forward interpretation output should use clearer Japanese emotional labels such as `遊びたい`, `さみしい`, `ねむたい`, `警戒している`.
11. Breed-specific reverse output is a planned expansion feature and must not be overclaimed in the current release.

## 7. Non-Functional Requirements
- Responsiveness: result display should appear within a few seconds after recording stops.
- Privacy: audio remains local in the MVP.
- Portability: core logic should be reusable in later mobile ports.
- Usability: the first-time user should understand how to record within a few seconds.
- Resilience: microphone absence or permission issues should be surfaced clearly.

## 8. Risks and Assumptions
### Risks
- There is no reliable general-purpose dataset for literal dog-language translation.
- Acoustic heuristics may misclassify noisy environments.
- Windows audio-device behavior can differ across machines.

### Assumptions
- The first MVP is acceptable as an "emotion estimation" product.
- Local heuristic analysis is sufficient for a first release.
- Reverse mode can be explicitly labeled as experimental.
- A small pre-release scope increase is acceptable if it improves user trust and usability without requiring a model-platform rewrite.

## 9. MVP Acceptance Criteria
- A Windows user can record audio through a microphone.
- The app returns an interpretation text with confidence wording.
- The app handles empty or invalid recordings gracefully.
- The app offers a visible reverse-mode workflow for human text input.
- The app keeps the core interpretation logic separate from UI concerns.

## 10. Pre-release Expansion Boundary
### Add before release
- waveform visualization during recording
- microphone device selection
- richer Japanese emotional phrasing in forward mode

### Defer to expansion phase unless explicitly reduced in scope
- higher-fidelity dog-voice rendering
- breed selection and breed-specific reverse sound profiles
