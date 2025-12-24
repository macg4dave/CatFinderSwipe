# CatFinderSwipe Roadmap

This roadmap keeps the project **100% Swift + Xcode** (SwiftUI + URLSession + SwiftData + DocC + XCTest/Swift Testing).

## Guiding principles

- No third-party dependencies (unless explicitly approved).
- Offline-tolerant UI (clear messaging, no crashes).
- Fast swipe loop (prefetch + caching).
- Privacy-first (store locally, be explicit about network use).

## MVP: Swipe cats (complete)

- [x] App boots into swipe UI (no template list UI)
  - [ ] Verify fresh install launches directly into swipe UI on a physical device.
- [x] Fetch random cat metadata over the network
  - [ ] Verify slow/failed network responses surface a friendly error and allow retry.
- [x] Display cat photo in a swipeable card
  - [ ] Verify rendering on small and large phones (light/dark mode).
- [x] Swipe left = seen
  - [ ] Verify "seen" persists across relaunch.
- [x] Swipe right = favorite + seen
  - [ ] Verify both favorite and seen are persisted in the same swipe.
- [x] Favorites list screen
  - [ ] Verify Favorites loads quickly with many items and no missing images crash.

## Milestone 2: Robustness

- [x] Loading/empty/error UI states refined
  - [ ] Force each state on device (loading, empty, error) and confirm copy.
- [x] Avoid repeats more aggressively (persist seen IDs, limit retries)
  - [ ] Confirm repeat prevention across app relaunches.
- [ ] Add simple "Clear Data" debug option
  - [ ] Add a debug button that calls `CatDecisionStore.clearAll()` and clears image caches.
- [ ] Add reachability-friendly messaging (no hard-crash when offline)
  - [ ] Add `NWPathMonitor` and show offline state with retry guidance.

## Milestone 3: Performance & caching

- [x] Image caching (memory + disk) to reduce network + speed up Favorites
  - [ ] Verify cache hits by logging or profiling repeated loads.
- [x] Prefetch the next image while viewing the current card
  - [ ] Confirm prefetch cancels in-flight work when the deck advances.
- [ ] Tune cache sizes and eviction (memory + disk)
  - [ ] Add disk size cap + eviction policy; validate memory cap impact.
- [ ] Ensure images are requested/scaled appropriately per device size
  - [ ] Downsample large images before caching to avoid oversized textures.
- [x] Image centering + aspect ratio handling
  - [ ] Verify no stretching or off-center crops across device sizes.
- [x] Image fills the card with consistent rounded corners
  - [ ] Verify no "corner gaps" or edge artifacts on swipe.

## Milestone 4: Testing

- [ ] Decode tests for API responses (fixture JSON)
  - [ ] Add fixtures and decode tests under unit tests target.
- [ ] Service tests with a stubbed `URLSession`
  - [ ] Use a custom `URLProtocol` to return canned responses.
- [ ] SwiftData store tests using in-memory containers
  - [ ] Verify favorites/seen persistence and clear/reset logic.
- [ ] UI test: swipe right adds a favorite
  - [ ] Add UI test that validates favorites count after swiping.
- [ ] UI test: swipe left marks seen and advances
  - [ ] Add UI test that ensures deck advances and seen state updates.

## Milestone 5: Polish

- [x] Haptics on commit
  - [ ] Verify haptics on a real device and respect system settings.
- [ ] Accessibility labels and actions for swipe controls
  - [ ] Add accessibility actions for "Like" and "Nope" on the card.
- [x] App icon + launch polish
  - [ ] Verify icon sizes and launch appearance on device.

## Milestone 6: Layout & interactions

- [x] Card layout: consistent rounded rectangle (95% wide, ~90% tall)
  - [ ] Verify layout on all supported device sizes and orientations.
- [x] Swiped images do not change size between cards
  - [ ] Verify size stability across multiple swipes.
- [x] Remove "Cats" title from the swipe screen
  - [ ] Verify no title appears on the swipe screen.
- [x] Haptics on swipe left (parity with swipe right)
  - [ ] Verify swipe-left haptics on device.
- [x] Background: random solid color per swipe
  - [ ] Verify background changes per swipe and stays subtle.
- [x] Favorites grid layout (thumbnails only; no filenames)
  - [ ] Verify grid spacing and tap targets on small screens.
- [x] Remove favorites (unfavorite) from the Favorites screen
  - [ ] Verify remove works from grid and detail.

## Milestone 7: Fun feedback

- [x] Swipe right: happy cat emoji bubbles up from bottom
  - [ ] Verify Like burst triggers on device.
- [x] Swipe left: sad cat emoji bubbles down
  - [ ] Verify Nope burst triggers on device.

## Milestone 8: Sharing

- [x] Share a favorite cat image from Favorites via Apple share sheet
  - [ ] Verify Share opens on device and includes image.

## Milestone 9: Fine-tuning

- [x] Swiped card offscreen before loading the next one
  - [ ] Verify smooth transition without flicker, blank states, or loading the next card in the same card view.
- [x] Optimize network requests to avoid redundant fetches when rapidly swiping (load 10 images ahead)
- [x] Change image height to 90% of screen height

## Non-goals (for now)

- Accounts/login
- Server-side favorites sync
- Non-Swift tooling or build systems
