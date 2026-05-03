# DogTranslator Requirements Definition

## 1. Product Vision
DogTranslator is a Windows-first application that listens to dog vocalizations, estimates likely emotional intent, and presents that interpretation as user-readable text. The product also supports a reverse mode where human text is transformed into dog-like expressive output for playful interaction.

## 2. Positioning
- Primary position: companion / entertainment plus behavioral hinting tool
- Explicitly not: scientifically validated literal language translation
- Recommended wording: `interpretation`, `emotion estimation`, `intent hint`

## 3. Target Users
- Dog owners who want a playful interpretation of their dog's vocal state
- Families and children who want an interactive pet communication experience
- Early testers interested in audio AI and animal-interaction experiments

## 4. User Scenarios
1. A user records a short bark and receives an on-screen interpretation such as `遊びたい` or `警戒している`.
2. A user records repeated whining and receives a calmer interpretation such as `さみしい / 甘えたい` or `安心したい`.
3. A user types a short human message and asks the app to render a dog-style expressive response.
4. A user reviews recent translations to compare multiple recordings.
5. A user registers an individual dog profile and wants the app to remember that dog's breed, age, and size.
6. A user wants to keep improving the app by labeling whether the estimated emotion matched the real-world situation.

## 5. MVP+ Scope
### In Scope
- Windows desktop application
- Microphone audio capture
- Short-session audio recording and stop control
- Heuristic interpretation of recorded dog vocalizations
- Display of translated / estimated text on screen
- Experimental reverse mode: human text to dog-style expression output
- Session history with local persistence
- Japanese emotional interpretation labels for forward mode
- Microphone device selection
- Live recording waveform
- Multiple emotion candidates for forward interpretation
- Recording quality guidance
- Dog profile registration and selection
- Scene-mode tagging
- Reverse mode controls for breed, age stage, size, and tension
- Analytics dashboard from local history
- User feedback labeling for saved results
- Inference provider abstraction for future model replacement
- Responsive layout preparation for later mobile reuse

### Out of Scope
- Scientifically validated dog-language translation
- Veterinary diagnosis or behavioral treatment advice
- Cloud-hosted model service in the current release candidate
- Multi-user sync
- Android and iPhone shipping in the current phase
- Learned breed-specific voice synthesis from recorded datasets

## 6. Functional Requirements
1. The app must allow the user to start and stop microphone recording.
2. The app must analyze the latest recorded audio and produce an interpretation label, explanation, confidence, and candidate list.
3. The app must show confidence as qualitative text, not false precision.
4. The app must provide recording quality guidance such as short input, noisy input, or weak signal.
5. The app must allow the user to enter Japanese or English text in reverse mode.
6. The reverse mode must produce a dog-style expressive output that can be played back.
7. The reverse mode must let the user choose breed, age stage, size, and tension preset.
8. The app must preserve interaction history across sessions.
9. The app must allow the user to store and switch dog profiles.
10. The app must allow the user to assign a manual feedback label to saved forward results.
11. The app must show dashboard summaries derived from saved history.
12. The app should allow the user to choose the microphone input device on Windows.
13. The app should show a simple live waveform or level trace while recording.
14. The core inference path should be replaceable later without rewriting the UI.

## 7. Non-Functional Requirements
- Responsiveness: result display should appear within a few seconds after recording stops.
- Privacy: audio and history remain local in this phase.
- Portability: core logic should be reusable in later mobile ports.
- Usability: the first-time user should understand how to record and switch dogs quickly.
- Resilience: microphone absence or permission issues should be surfaced clearly.

## 8. Risks and Assumptions
### Risks
- There is no reliable general-purpose dataset for literal dog-language translation.
- Acoustic heuristics may misclassify noisy environments.
- Windows audio-device behavior can differ across machines.
- User-labeled feedback may be subjective and noisy.

### Assumptions
- This phase remains an `emotion estimation` product, not literal translation.
- Local heuristic analysis is sufficient for the current release candidate.
- Reverse mode can remain explicitly labeled as experimental.
- Breed, age, and tension presets can be heuristic rather than data-driven in this phase.

## 9. MVP+ Acceptance Criteria
- A Windows user can record audio through a microphone.
- The app returns an interpretation text with confidence wording and candidate alternatives.
- The app handles empty or invalid recordings gracefully and gives quality guidance.
- The app persists history, profiles, and feedback labels locally.
- The app offers a visible reverse-mode workflow for text input plus breed / age / size / tension controls.
- The app shows dashboard summaries from saved interactions.
- The app keeps the inference path separate from UI concerns.
