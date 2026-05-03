# Skill.md

## Specification Phase Skill
Use this phase to convert approved requirements into concrete product behavior, interfaces, rules, and acceptance conditions.

## Goals
- Define exact input/output behavior.
- Remove ambiguity around recording, inference, result rendering, and playback.
- Prepare implementation-ready module and API expectations.

## Work Style
- Use explicit option comparison when choices are still open.
- Prefer "3 options -> criteria -> chosen option -> why" for major decisions.
- Record edge cases and error handling, not only the happy path.

## Required Outputs
- `specification.md`
- `ToDo.md`
- task files for unresolved specifications

## Required Sections
- feature behavior
- user flow details
- audio input rules
- translation output rules
- TTS behavior
- human-text-to-dog-sound behavior
- error handling
- acceptance tests

## Phase Questions
- How long can recording run, and how does it stop?
- How are uncertainty and confidence expressed?
- What exact data shape moves between UI, audio, and inference modules?
- What counts as a valid first implementation for reverse translation?
