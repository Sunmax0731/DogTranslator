# Task: Installer Release Preparation

## Objective
Define release requirements for shipping DogTranslator as a Windows installer while keeping Dog2vec model weights out of the base app payload.

## Requirements
- The installer must place the Windows app in a standard per-user location.
- The installer must automatically provision Dog2vec runtime prerequisites without manual editing of config files.
- Large model data must be downloaded during install instead of being bundled in the app payload.
- Runtime-specific settings must be removable by the uninstaller.
- The app must still degrade safely to heuristic inference when the runtime is unavailable.

## Acceptance
- Aggregate requirements document includes installer/bootstrap constraints.
- Release plan reflects installer-first packaging rather than zip-only packaging.
