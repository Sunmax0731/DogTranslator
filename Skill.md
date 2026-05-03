# Skill.md

## Repository Skill
This repository is operated as a docs-first, task-driven Windows application project with future mobile expansion in scope.

## Core Objective
- Build a Windows MVP that accepts dog vocal audio from a microphone, estimates meaning or emotional intent, and returns text plus optional speech output.
- Evaluate a reverse path where human text is converted into dog-like vocal playback.
- Preserve architectural seams so Android and iPhone versions can reuse core logic later.

## Default Operating Mode
- Work from milestone and task documents, not from ad hoc chat memory.
- Prefer small, reviewable tasks with clear completion criteria.
- Update the relevant phase documentation while doing the work.
- Keep conclusions evidence-based. Where the domain is uncertain, document assumptions explicitly.

## Delivery Milestones
1. Requirements
2. Specification
3. Design
4. Implementation
5. Test
6. Release

## Required Artifacts
- Root `ToDo.md`
- `01-requirements/requirements-definition.md`
- `02-specification/specification.md`
- `03-design/design.md`
- `04-implementation/implementation-report.md`
- `05-test/test-plan.md`
- `06-release/release-plan.md`
- `Agents.md`
- Root `Skill.md`
- Phase-specific `Skill.md` files

## Task-Driven Rules
- Each phase should have its own `ToDo.md`.
- Each actionable task should have its own Markdown file when the work is large enough to require context, decisions, or acceptance criteria.
- Aggregate phase documents should explain the overall judgment and structure so readers do not need to open every task file.
- Newly discovered work must be added to the backlog immediately.

## Git and Branch Discipline
- Use `main` as the integration branch.
- Start each task from up-to-date `main`.
- Create a dedicated task branch named `codex/<phase>-<task-summary>`.
- Merge each completed task back into `main` before starting too many additional branches.
- Keep simultaneous active task branches to at most two whenever possible.

## Product-Specific Guidance
- Phrase the feature honestly. Early versions should present outputs as interpretation or estimation, not scientific fact.
- Separate domain concepts:
  - dog audio capture and preprocessing
  - inference or rule-based interpretation
  - human-readable text generation
  - TTS and dog-sound playback
  - cross-platform adapters
- Prefer designs that allow replacement of the inference engine without rewriting the UI or audio layers.

## Definition of Done
- The target task document is updated.
- The relevant phase `ToDo.md` is updated.
- The aggregate phase document reflects important decisions.
- Validation steps and results are recorded.
- The task branch is ready to merge, or merged if Git is configured.
