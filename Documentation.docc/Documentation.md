# ``CatFinderSwipe``

A SwiftUI app that pulls random cat photos from a free public cat-photo API and lets you swipe left/right to mark cats as *seen* or *favorite*.

## Overview

CatFinderSwipe is intentionally **100% Swift + Xcode**:

- SwiftUI for UI
- Swift Concurrency (`async/await`) + `URLSession` for networking
- SwiftData for persistence (favorites + seen history)
- XCTest / Swift Testing for tests
- DocC for documentation

No CocoaPods, no Carthage, no JavaScript build steps, and no non-Swift runtime dependencies.

### User flow

- Launch the app to see a cat photo card.
- Swipe **right** to favorite.
- Swipe **left** to skip.
- View your favorites in the Favorites list.

### Architecture (high level)

- `CataasAPIClient` fetches random cat metadata and provides a normalized ``CatCard``.
- `SwipeDeckViewModel` owns deck state and swipe actions.
- `CatDecisionStore` persists decisions in SwiftData via ``FavoriteCat`` and ``SeenCat``.

## Running tests (recommended: on a real iPhone)

Some Macs struggle with iOS Simulators. This repo includes a helper script that is **device-first**.

1. Plug in your iPhone (USB or network), unlock it, and tap **Trust This Computer** if prompted.
2. In Xcode: set your Team / signing as needed for device builds.
3. Run tests on device:

```sh
bash scripts/test_on_device.sh
```

### Useful options

- List what your Mac sees (devices + destinations):

```sh
LIST_ONLY=1 bash scripts/test_on_device.sh
```

- Target a specific device UDID:

```sh
DEVICE_UDID=<your-udid-here> bash scripts/test_on_device.sh
```

- Include UI tests (skipped by default on device):

```sh
RUN_UI_TESTS=1 bash scripts/test_on_device.sh
```

- Simulator fallback is **opt-in** (not recommended):

```sh
ALLOW_SIMULATOR_FALLBACK=1 bash scripts/test_on_device.sh
```

## Topics

### UI

- ``SwipeDeckView``
- ``CatCardView``
- ``FavoritesView``

### View models

- ``SwipeDeckViewModel``

### Networking

- ``CataasAPIClient``
- ``CatAPIClientProtocol``

### Persistence

- ``FavoriteCat``
- ``SeenCat``
- ``CatDecisionStore``
