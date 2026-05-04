# DogTranslator 1.0.0 Release Notes

## Highlights
- Forward-only Windows desktop experience for dog-voice interpretation
- Local profile management, history replay, search, filtering, and dashboard summaries
- Optional Dog2vec local runtime with runtime-aware fallback to heuristic inference
- Theme presets, dark mode, microphone selection, and progress feedback during analysis
- Breed-aware expression icon presentation for top candidates

## Installer Behavior
- The Windows installer provisions the desktop app first
- Dog2vec runtime assets are then downloaded and configured automatically
- Uninstall removes installer-created runtime settings and downloaded model/runtime files

## Important Notes
- DogTranslator is an interpretation tool, not a validated literal translator
- The first install may take time because runtime dependencies and the Dog2vec model are downloaded
- If Dog2vec local runtime cannot be prepared, the app can still use heuristic inference

## Known Limitations
- Dog2vec integration currently relies on the base embedding model plus app-side mapping, not a product-specific trained classifier head
- Installer smoke validation still needs one clean-profile Windows pass before broader external distribution
- Reverse text-to-dog playback remains hidden from the release UI
