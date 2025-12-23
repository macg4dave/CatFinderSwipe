# CatFinderSwipe Roadmap

This roadmap is written to keep the project **100% Swift + Xcode** (SwiftUI + URLSession + SwiftData + DocC + XCTest/Swift Testing).

## MVP (Swipe cats)

- [x] App boots into swipe UI (no template list UI)
- [x] Fetch random cat metadata over the network
- [x] Display cat photo in a swipeable card
- [x] Swipe left = seen
- [x] Swipe right = favorite + seen
- [x] Favorites list screen
# CatFinderSwipe Roadmap

This roadmap is written to keep the project **100% Swift + Xcode** (SwiftUI + URLSession + SwiftData + DocC + XCTest/Swift Testing).

## MVP (Swipe cats)

- [x] App boots into swipe UI (no template list UI)
- [x] Fetch random cat metadata over the network
- [x] Display cat photo in a swipeable card
- [x] Swipe left = seen
- [x] Swipe right = favorite + seen
- [x] Favorites list screen


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
- [x] App icon + launch polish

## Milestone 6 fixes

- [ ] Card layout (95% wide, 75% tall, consistent rounded rectangle shape) forground
- [ ] Card layout (95% wide, 75% tall, consistent rounded rectangle shape) background
- [ ] swiped images do not change size
- [ ] remove "cats" title from top of swipe screen
- [ ] hapics on swipe left also
- [ ] happy cat emoji bubbling up on swipe right
- [ ] sad cat emoji bubbling down on swipe left


## Milestone 7 features

- [ ] share favorite cat images from favorites screen via apple share sheet


## Milestone 8 (Privacy, safety, compliance)

- [ ] Add a privacy summary section in Settings/About (what is stored locally, what is fetched remotely)
- [ ] App Tracking Transparency: confirm none needed; document rationale
- [ ] Basic content disclaimer + “Report issue” link (opens Mail or GitHub)


## Milestone 12 (Share & widgets)

- [ ] Home Screen widget: “Random favorite” / “Recent favorite”
- [ ] Share as image with watermark toggle (in-app render)
- [ ] Save to Photos (with permission handling)


## Non-goals (for now)

- Accounts/login
- Server-side favorites sync
- Non-Swift tooling or build systems

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
- [x] App icon + launch polish

## Milestone 6 fixes
[] Card layout (95% wide, 75% tall, consistent rounded rectangle shape) forground
[] Card layout (95% wide, 75% tall, consistent rounded rectangle shape) background
[] swiped images do not change size
[] remove "cats" title from top of swipe screen
[] hapics on swipe left also
[] happy cat emoji bubbling up on swipe right
[] sad cat emoji bubbling down on swipe left


##milestone 7 features
[] share favorite cat images from favorites screen via apple share sheet



## Non-goals (for now)

- Accounts/login
- Server-side favorites sync
- Non-Swift tooling or build systems

# CatFinderSwipe Roadmap

This roadmap is written to keep the project **100% Swift + Xcode** (SwiftUI + URLSession + SwiftData + DocC + XCTest/Swift Testing).

## MVP (Swipe cats)

- [x] App boots into swipe UI (no template list UI)
- [x] Fetch random cat metadata over the network
- [x] Display cat photo in a swipeable card
- [x] Swipe left = seen
- [x] Swipe right = favorite + seen
- [x] Favorites list screen


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
- [x] App icon + launch polish

## Milestone 6 fixes

- [ ] Card layout (95% wide, 75% tall, consistent rounded rectangle shape) forground
- [ ] Card layout (95% wide, 75% tall, consistent rounded rectangle shape) background
- [ ] swiped images do not change size
- [ ] remove "cats" title from top of swipe screen
- [ ] hapics on swipe left also
- [ ] happy cat emoji bubbling up on swipe right
- [ ] sad cat emoji bubbling down on swipe left


## Milestone 7 features

- [ ] share favorite cat images from favorites screen via apple share sheet


## Milestone 8 (Privacy, safety, compliance)

- [ ] Add a privacy summary section in Settings/About (what is stored locally, what is fetched remotely)
- [ ] App Tracking Transparency: confirm none needed; document rationale
- [ ] Basic content disclaimer + “Report issue” link (opens Mail or GitHub)


## Milestone 9 (Share & widgets)

- [ ] Home Screen widget: “Random favorite” / “Recent favorite”
- [ ] Share as image with watermark toggle (in-app render)
- [ ] Save to Photos (with permission handling)


## Non-goals (for now)

- Accounts/login
- Server-side favorites sync
- Non-Swift tooling or build systems

# CatFinderSwipe Roadmap

This roadmap is written to keep the project **100% Swift + Xcode** (SwiftUI + URLSession + SwiftData + DocC + XCTest/Swift Testing).

## MVP (Swipe cats)

- [x] App boots into swipe UI (no template list UI)
  - [ ] TODO: Verify fresh install launches directly into swipe UI on a physical device (not a simulator-only path).
- [x] Fetch random cat metadata over the network
  - [ ] TODO: Verify fetch works on slow networks and handles HTTP errors without crashing.
- [x] Display cat photo in a swipeable card
  - [ ] TODO: Verify image rendering on multiple device sizes (small + large iPhones) and in dark mode.
- [x] Swipe left = seen
  - [ ] TODO: Verify the “seen” state persists across relaunch (if persistence is intended for MVP).
- [x] Swipe right = favorite + seen
  - [ ] TODO: Verify favorite is persisted and also marked seen in the same transaction.
- [x] Favorites list screen
  - [ ] TODO: Verify favorites screen loads quickly with many items and handles missing images gracefully.

## Milestone 2 (Robustness)

- [x] Loading/empty/error UI states refined
  - [ ] TODO: Verify all three states are reachable and correct (loading, empty, error) on device.
- [x] Avoid repeats more aggressively (persist seen IDs, limit retries)
  - [ ] TODO: Verify repeats are actually prevented after relaunch and retry limits don’t cause dead-ends.
- [x] Add simple “Clear data” debug option
  - [ ] TODO: Verify it clears SwiftData + caches (if applicable) and resets swipe/favorites state.
- [x] Add reachability-friendly messaging (don’t hard-crash on offline)
  - [ ] TODO: Verify airplane mode/offline shows messaging and allows recovery when network returns.

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
  - [ ] TODO: Verify haptics fire on real device (not just simulator) and respect system haptics settings.
- [x] Accessibility labels for swipe actions
  - [ ] TODO: Verify with VoiceOver that swipe-left/right actions are discoverable and announced correctly.
- [x] App icon + launch polish
  - [ ] TODO: Verify icons for all required sizes and launch appearance on device (light/dark) with no warnings in Xcode.

## Milestone 6 fixes

- [ ] Card layout (95% wide, 75% tall, consistent rounded rectangle shape) forground
- [ ] Card layout (95% wide, 75% tall, consistent rounded rectangle shape) background
- [ ] swiped images do not change size
- [ ] remove "cats" title from top of swipe screen
- [ ] hapics on swipe left also
- [ ] happy cat emoji bubbling up on swipe right
- [ ] sad cat emoji bubbling down on swipe left

## milestone 7 features

- [ ] share favorite cat images from favorites screen via apple share sheet

## Non-goals (for now)

- Accounts/login
- Server-side favorites sync
- Non-Swift tooling or build systems
