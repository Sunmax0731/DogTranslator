# Inference Model Selection Task

## Specification Decisions
- Add three selectable modes:
  - `auto`
  - `heuristic`
  - `dog2vec_local`
- Persist the requested mode in app settings.
- Resolve an effective active mode at runtime based on local runtime availability.
- Surface fallback behavior in the forward UI so the user can see when heuristic mode is used instead of Dog2vec.
