# Forward-Only UI And Runtime Hardening Task

## Specification Decisions
- Restrict the visible app flow to Forward, Dashboard, and Settings.
- Keep reverse logic in code, but remove its UI entry points from the release surface.
- Replace candidate list-only emphasis with pie-chart visualization plus chip tooltips.
- Move app-wide settings and profile management into a dedicated Settings tab.
- Treat Dog2vec local runtime as an optional configured local enhancement with graceful fallback.
