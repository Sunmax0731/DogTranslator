# Pre-release Expansion Task

## Goal
Extend the Windows release scope beyond the initial MVP with user-visible audio and control improvements while keeping the product shippable.

## Requested Features
1. Show live waveform while recording.
2. Allow microphone input device selection.
3. Express dog-to-human interpretation using Japanese emotional phrases such as `遊びたい`, `さみしい`, `ねむたい`.
4. Improve human-to-dog conversion quality and allow breed selection.

## Delivery Classification
### Pre-release candidates
- Live waveform during recording
- Input microphone selection
- Richer Japanese emotional labels for forward interpretation

### Separate expansion track
- Higher-fidelity dog-voice rendering
- Breed-specific dog-voice selection

## Why This Split
- Items 1 to 3 strengthen the current Windows product without changing the core architecture drastically.
- Item 4 changes the reverse-generation model, asset strategy, and UX depth enough that it should be treated as a dedicated expansion phase unless a very small placeholder version is explicitly chosen.

## Done Condition
- Requirements, specification, design, and release plan all reflect the new scope split.
- The implementation backlog is updated in actionable order.
