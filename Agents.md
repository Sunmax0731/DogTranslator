# Agents.md

## Purpose
This repository builds a dog-voice translation application that starts on Windows and later expands to Android and iPhone.
Agents working in this repository must prioritize traceability, small task units, and delivery that can be merged cleanly to `main`.

## Working Principles
- Treat the repository as task-driven: every meaningful unit of work should be reflected in `ToDo.md` and the relevant phase folder.
- Keep documentation current while work progresses. Do not defer process updates until the end of a phase.
- Optimize for a Windows-first MVP, but avoid choices that block later mobile expansion.
- Distinguish clearly between validated capability and exploratory ideas. Do not describe speculative behavior as if it already works.
- For dog-language claims, use careful wording. Default to "emotion/intention estimation" unless stronger evidence exists.

## Standard Delivery Flow
1. Confirm the active phase and target task in `ToDo.md` and the relevant phase folder.
2. Sync `main` before starting new work.
3. Create one short-lived task branch, usually `codex/<phase>-<task-summary>`.
4. Complete the task end-to-end in that branch: docs, implementation, validation, and task status updates.
5. Merge the branch back into `main` after validation.
6. Delete or retire the merged branch before opening the next one.

## Branch Rules
- Use `main` as the stable branch.
- Use one branch per task.
- Avoid having more than two active non-`main` branches at the same time.
- If two branches already exist, merge or close one before starting another unless the user explicitly asks for parallel work.
- Prefer small branches that map to one task file or one tightly-related task cluster.
- Rebase or merge from updated `main` early if drift appears, instead of letting conflicts accumulate.

## GitHub Project Management Rules
- Use GitHub as the source of truth for task tracking once the repository is connected.
- Mirror each task in the relevant phase `ToDo.md`.
- Keep task titles consistent across local docs, branch names, commits, and GitHub Issues when possible.
- When a task is completed, update local docs and merge to `main` in the same delivery cycle.
- If a task reveals new work, add it immediately to the appropriate phase backlog instead of leaving it only in chat.

## Documentation Set
- Root `ToDo.md`: project index and milestone overview.
- `01-requirements` through `06-release`: one folder per phase.
- Each phase folder should contain:
  - `ToDo.md`
  - the phase aggregate deliverable
  - task files for that phase
  - phase-specific `Skill.md`

## Release Packaging Rules
- Treat the Windows installer as part of the product, not as an afterthought.
- When release packaging changes, update `README.md`, `06-release/release-plan.md`, and the relevant phase aggregates in the same task.
- If runtime or model assets are intentionally excluded from the base installer, document exactly how and when they are provisioned.
- If installer-created settings or environment variables exist, define both install-time creation and uninstall-time cleanup.

## Engineering Expectations
- Keep platform-dependent code isolated from reusable domain logic.
- Prefer interfaces around audio capture, TTS, and inference so mobile ports can replace adapters without rewriting core flows.
- Record technical decisions with rationale, especially around inference method, model hosting, privacy, and offline behavior.
- Treat microphone permission, audio retention, and user privacy as first-class concerns.

## Current Constraint
- Git is available locally and branch-based task flow is active.
- Do not claim remote publication or GitHub sync unless a remote operation was actually executed.
