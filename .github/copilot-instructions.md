## Project constraints (please follow)

- **100% Swift + Xcode.** Don’t introduce CocoaPods/Carthage/JS build steps. Avoid new third-party dependencies unless explicitly requested.
- Target a **SwiftUI + Swift Concurrency + SwiftData** app.
- Prefer **small, focused changes** that preserve existing public APIs and naming.
- When editing existing code, prefer **the smallest safe diff**:
  - Avoid broad refactors, renames, file moves, or reformatting unless required.
  - Preserve current behavior by default.
  - After changes, **double-check that existing features aren’t lost** (swipe flow, favorites list, caching/loading, error states).
  - If a change could alter behavior, call it out explicitly and add/adjust tests.
