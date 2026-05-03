# Skill.md

## Design Phase Skill
Use this phase to decide the technical architecture, component boundaries, and UI/UX structure that satisfy the specification and preserve future portability.

## Goals
- Choose the Windows-first stack.
- Define reusable core modules versus platform-specific adapters.
- Design screens, flows, and state transitions.

## Work Style
- Compare multiple architecture candidates before selecting one.
- Keep future Android/iPhone support visible in every major design choice.
- Document why alternatives were rejected.

## Required Outputs
- `design.md`
- `ToDo.md`
- task files for architecture or UX decisions

## Required Sections
- architecture options
- decision criteria
- selected architecture and rationale
- module boundaries
- data model
- UI flow
- portability strategy

## Phase Questions
- Which stack best serves Windows now without blocking mobile later?
- What belongs in shared core logic?
- Which interfaces isolate microphone, TTS, and playback differences?
- How should the app communicate uncertainty and experimental status to users?
