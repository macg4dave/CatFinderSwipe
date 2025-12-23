# CatFinderSwipe Roadmap

This roadmap is written to keep the project **100% Swift + Xcode** (SwiftUI + URLSession + SwiftData + DocC + XCTest/Swift Testing).

## MVP (Swipe cats)

- [x] App boots into swipe UI (no template list UI)
- [x] Fetch random cat metadata over the network
- [x] Display cat photo in a swipeable card
- [x] Swipe left = seen
- [x] Swipe right = favorite + seen
- [x] Favorites list screen

### MVP acceptance

- App shows a cat within a few seconds on a normal network.
- Swipe gestures feel responsive and don’t block on network calls.
- Favorites persist across app relaunch.

## Milestone 2 (Robustness)

- [x] Loading/empty/error UI states refined
- [x] Avoid repeats more aggressively (persist seen IDs, limit retries)
- [x] Add simple “Clear data” debug option
- [x] Add reachability-friendly messaging (don’t hard-crash on offline)

## Milestone 3 (Caching & performance)

- [ ] Image caching (memory + disk) to reduce network + speed up Favorites
- [ ] Prefetch next image
- [ ] Tune `URLCache` sizes and request policies
- [ ] Image is scaled appropriately for device screen size / resolution
- [ ] Image centering + aspect ratio handling
- [ ] Image in center in box that extends to edges (no weird corners on rounded cards)
- [ ] Background to be a random soild colour on every swipe

## Milestone 3.1
- [ ] Favorites grid view layout only with no file names
- [ ] if photo is liked then random cat emjoicons bubble up from bottom of screen

## Milestone 4 (Testing)

- [ ] Decode tests for API responses (fixture JSON)
- [ ] Service tests with stubbed URLSession
- [ ] SwiftData store tests using in-memory containers
- [ ] UI test: swipe right adds a favorite

> Note: tests are intended to be run on a connected physical iPhone/iPad using `bash scripts/test_on_device.sh`.

## Milestone 5 (Polish)

- [x] Haptics on commit
- [x] Accessibility labels for swipe actions
- [x] Undo last swipe
- [x] App icon + launch polish

## Milestone 6 fixes
Card layout (95% wide, 75% tall, consistent rounded rectangle shape) forground
Card layout (95% wide, 75% tall, consistent rounded rectangle shape) background
changed Favorite icon  to happy cat face emoji
have happy cat face emoji bubble up from bottom of screen when photo is liked
have sad cat face emoji bubble up from bottom of screen when photo is disliked


## Non-goals (for now)

- Accounts/login
- Server-side favorites sync
- Non-Swift tooling or build systems
