# Forward-Only UI And Runtime Hardening Task

## Completed Work
- Hid reverse mode from the active UI while preserving its code.
- Reworked the home shell into a forward-focused Windows workspace with Forward, Dashboard, and Settings.
- Added parameter tooltips, candidate pie chart, and radio-button feedback input.
- Added history search, date display, and replay for saved forward recordings.
- Added theme selection plus profile add/edit/delete inside Settings while preserving the existing add-profile shortcut.
- Added profile calibration aggregation and integrated it into forward scoring.
- Added `dog_voice_local/`, downloaded the Dog2vec base model, cloned the upstream helper repo, and created `dog2vec_runtime.json`.

## Validation
- `flutter analyze`
- `flutter test`
- `flutter build windows`
- `python dog_voice_local/app/infer.py --input dog_voice_local/sample_test.wav`
