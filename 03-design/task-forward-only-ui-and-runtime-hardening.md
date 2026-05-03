# Forward-Only UI And Runtime Hardening Task

## Design Summary
- Move from a hero-led two-mode layout to a utility-style Windows workspace.
- Preserve reverse implementation behind the architecture boundary, but remove it from active navigation.
- Centralize durable settings and profile management in a Settings tab.
- Keep Dog2vec integration external and optional through a local runtime boundary plus runtime config file.
- Personalize forward scoring with lightweight profile calibration aggregates instead of retraining.
