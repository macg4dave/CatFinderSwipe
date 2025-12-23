#!/usr/bin/env bash
set -euo pipefail

# Runs tests on a connected physical iPhone/iPad.
#
# Device-first by default:
# - If no physical device is found, the script exits with a helpful message.
# - You can opt into simulator fallback by setting ALLOW_SIMULATOR_FALLBACK=1.
#
# Environment variables:
# - DEVICE_UDID: Run tests on this specific device UDID.
# - RUN_UI_TESTS=1: Include UI tests (skipped by default on device).
# - LIST_ONLY=1: Print detected devices/destinations and exit.
# - ALLOW_SIMULATOR_FALLBACK=1: If no device is found, run on any simulator destination.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_PATH="$ROOT_DIR/CatFinderSwipe.xcodeproj"
SCHEME="CatFinderSwipe"
DERIVED_DATA_PATH="$ROOT_DIR/DerivedData"

RUN_UI_TESTS="${RUN_UI_TESTS:-0}"
DEVICE_UDID="${DEVICE_UDID:-}"
LIST_ONLY="${LIST_ONLY:-0}"
ALLOW_SIMULATOR_FALLBACK="${ALLOW_SIMULATOR_FALLBACK:-0}"

function require_tool() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required tool: $1" >&2
    exit 1
  fi
}

require_tool xcodebuild
require_tool xcrun

function show_helpful_destinations() {
  # Some environments (older Xcodes, misconfigured schemes) can yield empty output.
  # We keep this best-effort and never rely on it exclusively.
  xcodebuild -showdestinations -project "$PROJECT_PATH" -scheme "$SCHEME" 2>/dev/null || true
}

function list_connected_ios_device_udids() {
  # Prefer xctrace, which tends to be more reliable than parsing xcodebuild.
  # Example line: "My iPhone (18.6) (00008140-00151542223A801C)"
  xcrun xctrace list devices 2>/dev/null \
    | grep -E "\(.*\) \([0-9A-Fa-f-]{25,}\)$" \
    | grep -v -E "Simulator\)" \
    | grep -v -E "Mac\)" \
    | sed -n 's/.*(\([0-9A-Fa-f-]\{25,\}\))$/\1/p' \
    | cat
}

function pick_default_device_udid() {
  local udid
  udid=$(list_connected_ios_device_udids | head -n 1 || true)
  if [[ -n "$udid" ]]; then
    echo "$udid"
    return 0
  fi
  return 1
}

function find_simulator_destination() {
  # Best-effort simulator destination, only used when ALLOW_SIMULATOR_FALLBACK=1.
  local line
  line=$(show_helpful_destinations | grep -E "\{ platform:iOS Simulator," | head -n 1 || true)
  if [[ -n "$line" ]]; then
    local id
    id=$(echo "$line" | sed -n 's/.*id:\([^,}]*\).*/\1/p')
    if [[ -n "$id" ]]; then
      echo "id=$id"
      return 0
    fi
  fi
  echo "platform=iOS Simulator"
}

function run_tests() {
  local destination="$1"
  local is_device="$2" # 1 or 0

  local args=(
    test
    -project "$PROJECT_PATH"
    -scheme "$SCHEME"
    -destination "$destination"
    -derivedDataPath "$DERIVED_DATA_PATH"
  )

  if [[ "$RUN_UI_TESTS" != "1" ]]; then
    args+=( -skip-testing:CatFinderSwipeUITests )
  fi

  if [[ "$is_device" == "1" ]]; then
    args+=( -allowProvisioningUpdates )
  fi

  xcodebuild "${args[@]}" | cat
}

if [[ "$LIST_ONLY" == "1" ]]; then
  echo "Connected physical iOS device UDIDs (from xctrace):"
  list_connected_ios_device_udids || true
  echo
  echo "xcodebuild -showdestinations (best effort):"
  show_helpful_destinations | cat
  exit 0
fi

DESTINATION=""
if [[ -n "$DEVICE_UDID" ]]; then
  DESTINATION="id=$DEVICE_UDID"
  echo "✅ Using DEVICE_UDID: $DESTINATION"
  echo "   (UI tests skipped by default; set RUN_UI_TESTS=1 to include them.)"
  run_tests "$DESTINATION" 1
  exit $?
fi

if udid=$(pick_default_device_udid); then
  DESTINATION="id=$udid"
  echo "✅ Found connected iOS device. Running tests on physical device ($DESTINATION)."
  echo "   (UI tests skipped by default; set RUN_UI_TESTS=1 to include them.)"
  run_tests "$DESTINATION" 1
  exit $?
fi

echo "❌ No connected physical iOS device detected."

echo "Troubleshooting:"
cat <<'EOF'
- Plug in the iPhone (USB or network), unlock it, and tap Trust if prompted.
- In Xcode: Window ▸ Devices and Simulators ▸ select the device and confirm it appears.
- Ensure you installed/selected Xcode Command Line Tools (xcode-select -p).
- Run LIST_ONLY=1 bash scripts/test_on_device.sh to see what your Mac detects.
- If you really want simulator fallback: set ALLOW_SIMULATOR_FALLBACK=1.
EOF

if [[ "$ALLOW_SIMULATOR_FALLBACK" == "1" ]]; then
  DESTINATION=$(find_simulator_destination)
  echo
  echo "↩︎ Falling back to simulator ($DESTINATION)."
  run_tests "$DESTINATION" 0
  exit $?
fi

exit 2
