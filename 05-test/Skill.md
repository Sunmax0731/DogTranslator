# Skill.md

## Test Phase Skill
Use this phase to verify behavior against requirements and specification using explicit commands, environments, and expected results.

## Goals
- Confirm the Windows MVP actually works in realistic environments.
- Distinguish automated coverage from manual audio-device verification.
- Record known limitations honestly.

## Work Style
- Every test item should state command, working directory, required environment, and expected result.
- Keep manual and automated test coverage separate but linked.
- Prioritize audio-device, microphone, noise, and permission edge cases.

## Required Outputs
- `test-plan.md`
- `ToDo.md`
- task files for test gaps, regressions, and evidence capture

## Required Sections
- test scope
- environment matrix
- automated tests
- manual tests
- edge cases
- defect log
- exit criteria

## Phase Questions
- Which behavior is unit-testable and which requires a real microphone/device?
- How is translation uncertainty verified?
- What happens when audio input quality is poor?
- What minimum evidence is needed before release?
