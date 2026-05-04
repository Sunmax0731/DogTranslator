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
- `05-test`: complete
- `06-release`: in progress

## Active Tasks
- [x] Create repository operating documents (`Agents.md`, root `Skill.md`, phase `Skill.md`)
- [x] Create milestone and phase documentation skeleton
- [x] Implement Windows MVP using Flutter
- [x] Execute automated validation
- [x] Resolve Windows build environment prerequisites and run desktop build
- [x] Expand pre-release scope with waveform, mic selection, and richer Japanese emotion labels
- [x] Add breed-aware reverse mode controls and synthesis presets
- [x] Implement MVP+ persistence, profiles, dashboard, ranked candidates, and inference abstraction
- [x] Rework forward inference for Dog2vec-ready staged interpretation
- [x] Add local process inference bridge and resilient fallback path
- [x] Improve forward accuracy with richer audio features, calibrated scoring, and clean Japanese labels
- [x] Add selectable inference model settings with runtime-aware fallback
- [x] Refocus the visible product on forward interpretation and hide reverse mode UI
- [x] Add settings tab, theme presets, richer history controls, and result tooltips
- [x] Add profile calibration support and candidate pie-chart visualization
- [x] Acquire Dog2vec local runtime assets and validate the Python runtime entrypoint
- [x] Expand analysis progress UI with more stages, ETA, and dimmed stale results
- [x] Add history tag filters, selection-driven result recall, and GUI delete actions
- [x] Add dashboard-driven history filtering and profile-scoped analytics
- [x] Move microphone selection into Settings and add dark mode theme
- [x] Define installer-based release packaging with post-install Dog2vec bootstrap
- [x] Build local installer artifact and runtime cleanup scripts
- [ ] Finalize release notes and publishable distribution checklist

## Branch Policy
- Base branch: `main`
- Task branches: `codex/<phase>-<task-summary>`
- Keep active non-`main` branches to at most two whenever possible.
- Merge completed task branches back to `main` before starting too many parallel tasks.

## Current Delivery Sequence
1. `codex/docs-foundation`: documentation and planning artifacts
2. `codex/flutter-mvp`: Windows MVP implementation and testing
3. `codex/release-prep-installer`: installer-oriented release preparation and runtime bootstrap

## Notes
- Branch and merge operations are currently local unless a remote is configured and used explicitly.
- Early "translation" results must be framed as interpretation or estimation, not scientific fact.
- Release packaging now targets a per-user Windows installer that bootstraps Dog2vec runtime assets after app files are installed.
