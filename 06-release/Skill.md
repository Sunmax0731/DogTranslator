# Skill.md

## Release Phase Skill
Use this phase to package, document, version, and publish a validated build without overstating readiness.

## Goals
- Produce a clear Windows installer package.
- Publish user-facing guidance and limitations.
- Prepare the backlog for post-release and mobile expansion.

## Work Style
- Release only from validated `main`.
- Ensure release notes align with what has actually been tested.
- Treat known limitations and disclaimers as mandatory content.

## Required Outputs
- `release-plan.md`
- `ToDo.md`
- task files for packaging, versioning, and publication work

## Required Sections
- release scope
- versioning
- packaging format
- installation steps
- runtime bootstrap steps
- uninstall cleanup behavior
- known limitations
- release notes
- post-release backlog

## Phase Questions
- What exactly is being shipped in this release?
- What user setup is required on Windows, and what is automated by the installer?
- How are privacy, audio retention, and experimental accuracy disclosed?
- What work should remain explicitly deferred to Android/iPhone phases?
