# Task: Installer Release Preparation

## Objective
Choose and document the release packaging architecture for a Windows-first DogTranslator installer.

## Design Decision
- Chosen installer technology: Inno Setup
- Chosen deployment mode: per-user install under LocalAppData
- Chosen runtime strategy: bootstrap Dog2vec local runtime after app install

## Why
- Avoids requiring admin rights for the default install path.
- Keeps the installer lighter than bundling model weights.
- Allows runtime-specific settings and downloaded assets to be cleaned up by the uninstaller.
