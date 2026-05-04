# Task: Installer Release Preparation

## Objective
Specify the installation, runtime bootstrap, configuration discovery, and uninstall behavior for the Windows release package.

## Specification Points
- Installer copies Flutter desktop build output.
- Installer bundles bootstrap-only Dog2vec runtime sources, not model weights.
- Post-install script downloads:
  - Python runtime if needed by the packaged runtime flow
  - Python dependencies
  - upstream Dog2vec helper code
  - Dog2vec weight file
- Post-install script writes runtime config JSON and any required environment variables.
- Uninstaller removes runtime config, downloaded runtime assets, and installer-created environment settings.

## Acceptance
- Aggregate specification document lists install/runtime/uninstall behavior and expected paths.
