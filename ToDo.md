# DogTranslator ToDo

## Project Overview
- Product: DogTranslator
- Goal: Build a Windows MVP for dog-voice interpretation, then expand to Android and iPhone with shared core logic.
- Delivery style: task-driven development with phase-specific documents and task files.

## Milestones
1. `01-requirements`: define MVP scope and constraints
2. `02-specification`: define exact behaviors and acceptance conditions
3. `03-design`: select stack and architecture
4. `04-implementation`: build the Windows MVP
5. `05-test`: validate behavior and document evidence
6. `06-release`: prepare packaging and release planning

## Current Status
- `01-requirements`: complete
- `02-specification`: complete
- `03-design`: complete
- `04-implementation`: complete
- `05-test`: complete with environment blocker noted
- `06-release`: pending

## Active Tasks
- [x] Create repository operating documents (`Agents.md`, root `Skill.md`, phase `Skill.md`)
- [x] Create milestone and phase documentation skeleton
- [x] Implement Windows MVP using Flutter
- [x] Execute automated validation
- [x] Resolve Windows build environment prerequisites and run desktop build
- [x] Expand pre-release scope with waveform, mic selection, and richer Japanese emotion labels
- [x] Add breed-aware reverse mode controls and synthesis presets
- [ ] Prepare release package plan

## Branch Policy
- Base branch: `main`
- Task branches: `codex/<phase>-<task-summary>`
- Keep active non-`main` branches to at most two whenever possible.
- Merge completed task branches back to `main` before starting too many parallel tasks.

## Current Delivery Sequence
1. `codex/docs-foundation`: documentation and planning artifacts
2. `codex/flutter-mvp`: Windows MVP implementation and testing

## Notes
- Until a GitHub remote is configured, branch and merge operations are local only.
- Early "translation" results must be framed as interpretation or estimation, not scientific fact.
