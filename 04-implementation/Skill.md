# Skill.md

## Implementation Phase Skill
Use this phase to build the approved design in small, mergeable tasks with repeatable validation.

## Goals
- Implement the Windows MVP incrementally.
- Keep the branch size small and traceable to tasks.
- Preserve clean separation between core logic and device/platform adapters.

## Work Style
- One task branch per implementation unit.
- Update docs and task status during the work, not after.
- Prefer testable modules over monolithic UI logic.

## Required Outputs
- `implementation-report.md`
- `ToDo.md`
- task files for each implementation unit
- source code and validation evidence

## Required Sections
- implementation scope
- completed modules
- pending modules
- technical notes
- validation summary

## Phase Questions
- Is the current task small enough for one branch and one merge?
- Did the work preserve cross-platform seams?
- Were logging, error paths, and fallback behavior handled?
- Was validation captured in a way another person can rerun?
