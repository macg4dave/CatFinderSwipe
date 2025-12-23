# Milestone 9 (Widgets & Save to Photos)

This repo currently contains only Swift source files (no `.xcodeproj`, no `Info.plist`, no entitlements). The code is implemented, but you must wire it up in Xcode for it to run on device.

## 1) Save to Photos

### What’s implemented

- `Utilities/PhotoLibrarySaver.swift`
- “Save to Photos” action in Favorites grid (context menu)
- “Save” toolbar button in Favorite detail view

### Xcode setup required

Add this key to the **app target** Info.plist:

- `NSPhotoLibraryAddUsageDescription` (String)
  - Example: `"Save favorite cat photos to your library."`

Then run on a real device to fully validate.

## 2) Home Screen widget (Random Favorite)

### Widget code implemented

- `Widgets/CatFinderSwipeWidget.swift` (WidgetKit Extension code)
- `Utilities/WidgetFavoritesExport.swift` (exports favorites to the App Group container as `favorites.json`)
- Hooks into favorites add/remove/clear to keep the export up to date

### Xcode setup required (critical)

1. **Add a Widget Extension target**
   - Xcode: File > New > Target… > **Widget Extension**
2. **Add App Groups capability** to BOTH targets:
   - Main app target
   - Widget extension target
3. Pick an App Group identifier, e.g.:
   - `group.com.macg4dave.CatFinderSwipe`
4. Set the same identifier in BOTH places:
   - `Utilities/WidgetFavoritesExport.swift` → `WidgetFavoritesExport.appGroupId`
   - `Widgets/CatFinderSwipeWidget.swift` → `AppGroup.id`
5. Ensure the widget extension includes `Widgets/CatFinderSwipeWidget.swift`.

### Notes

- Widgets can’t directly reuse the in-app `ImagePipeline` actor. The widget uses `AsyncImage`.
- The widget refreshes periodically and also calls `WidgetCenter.shared.reloadAllTimelines()` after exports.

## Validation checklist

- Add/remove favorites → widget updates within ~30 minutes (or immediately after timeline reload)
- Save to Photos prompts permission once and then successfully saves
