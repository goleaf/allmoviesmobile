#!/bin/bash
set -euo pipefail

# macos_cursor_runner.sh
# -----------------------
# Helper script to run the AllMovies Flutter app locally on macOS without
# Android Studio. Supports running on:
#   - iOS Simulator (Xcode tools)
#   - Android emulator (Android SDK tools)
#
# Defaults to Google Chrome (web) when no device is specified; otherwise prefers
# iOS Simulator on macOS if Xcode tools are available, then Android if
# ANDROID_SDK_ROOT is configured.

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$HOME/Library/Android/sdk}"
AVD_NAME="${AVD_NAME:-allmovies_pixel_5_api_34}"
IOS_DEVICE_NAME="${IOS_DEVICE_NAME:-iPhone 15}"
PLATFORM="auto"   # auto|ios|android (can be overridden via --platform)
DEVICE_ID=""      # optional explicit device id for flutter run
EMULATOR_SERIAL=""
LOCAL_PROPERTIES="$PROJECT_ROOT/local.properties"

usage() {
  cat <<USAGE
Usage: $0 [--skip-build] [--skip-emulator] [--avd-name <name>]

Options:
  --platform <p>     Target platform: ios | android | auto
  --device-id <id>   Explicit Flutter device id to target (from `flutter devices`).
  --avd-name <name>  Android emulator AVD name to boot (android only).
  --ios-device <nm>  iOS Simulator device name to prefer (best-effort).
  --skip-build       Skip `flutter pub get` (useful if deps are already fetched).
  --skip-emulator    Do not start or interact with simulator/emulator.

Defaults:
  If no device is specified and platform is 'auto', launches on 'chrome' (or 'web-server' if Chrome is unavailable).

Environment variables:
  ANDROID_SDK_ROOT   Location of the Android SDK. Defaults to
                     \"$HOME/Library/Android/sdk\" on macOS.
  AVD_NAME           Alternate way to override the emulator name.
USAGE
}

log() {
  printf "[macos-cursor] %s\n" "$*"
}

require_file() {
  if [[ ! -e "$1" ]]; then
    log "Missing dependency at $1"
    return 1
  fi
}

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    log "Missing required command: $1"
    return 1
  fi
}

require_flutter() {
  if ! command -v flutter >/dev/null 2>&1; then
    log "Flutter is not installed or not in PATH. Install from https://flutter.dev and ensure 'flutter' is on PATH."
    exit 1
  fi
}

flutter_pub_get() {
  log "Running: flutter pub get"
  (cd "$PROJECT_ROOT" && flutter pub get)
}

adb_path() {
  echo "$ANDROID_SDK_ROOT/platform-tools/adb"
}

emulator_path() {
  echo "$ANDROID_SDK_ROOT/emulator/emulator"
}

ensure_android_tools() {
  require_file "$(adb_path)"
  require_file "$(emulator_path)"
}

ensure_ios_tools() {
  if ! command -v xcrun >/dev/null 2>&1; then
    return 1
  fi
  if ! xcrun simctl help >/dev/null 2>&1; then
    return 1
  fi
  if [[ ! -e "/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app" ]] && ! open -Ra Simulator >/dev/null 2>&1; then
    return 1
  fi
  return 0
}

# Ensure Gradle knows where the Android SDK is.
# - Exports ANDROID_SDK_ROOT and ANDROID_HOME for compatibility
# - Creates/updates local.properties with sdk.dir when missing
ensure_android_sdk_config() {
  local sdk_dir
  sdk_dir="$ANDROID_SDK_ROOT"

  if [[ -z "$sdk_dir" || ! -d "$sdk_dir" ]]; then
    log "Android SDK not found at '$sdk_dir'"
    log "Set ANDROID_SDK_ROOT or install the SDK to $HOME/Library/Android/sdk"
    exit 1
  fi

  export ANDROID_SDK_ROOT="$sdk_dir"
  export ANDROID_HOME="$sdk_dir"

  if [[ -f "$LOCAL_PROPERTIES" ]]; then
    if grep -q '^sdk\.dir=' "$LOCAL_PROPERTIES"; then
      : # already configured
    else
      log "Adding sdk.dir to existing local.properties"
      printf "\nsdk.dir=%s\n" "$sdk_dir" >>"$LOCAL_PROPERTIES"
    fi
  else
    log "Creating local.properties with sdk.dir=$sdk_dir"
    printf "sdk.dir=%s\n" "$sdk_dir" >"$LOCAL_PROPERTIES"
  fi
}

# Prefer JDK 17 for AGP/Kotlin compatibility to avoid KAPT issues on newer JDKs
ensure_java_home() {
  if command -v /usr/libexec/java_home >/dev/null 2>&1; then
    if /usr/libexec/java_home -v 17 >/dev/null 2>&1; then
      export JAVA_HOME="$([ -z "${JAVA_HOME:-}" ] && /usr/libexec/java_home -v 17 || echo "$JAVA_HOME")"
      # If JAVA_HOME was empty, the command above set it; ensure it's 17
      if [[ ! -x "$JAVA_HOME/bin/java" ]]; then
        export JAVA_HOME="$(! /usr/libexec/java_home -v 17 2>/dev/null || true)"
      fi
      if /usr/libexec/java_home -v 17 >/dev/null 2>&1; then
        export JAVA_HOME="$(/usr/libexec/java_home -v 17)"
      fi
      export PATH="$JAVA_HOME/bin:$PATH"
      log "Using JAVA_HOME=$JAVA_HOME"
    else
      log "JDK 17 not found; using system default JAVA_HOME"
    fi
  fi
}

cleanup_emulator() {
  local adb
  adb="$(adb_path)"
  if [[ -z "$EMULATOR_SERIAL" ]]; then
    EMULATOR_SERIAL="emulator-5554"
  fi
  "$adb" -s "$EMULATOR_SERIAL" emu kill >/dev/null 2>&1 || true
}

boot_emulator() {
  local emulator_bin
  emulator_bin="$(emulator_path)"

  if pgrep -f "emulator.*$AVD_NAME" >/dev/null 2>&1; then
    log "Emulator $AVD_NAME already running."
    return
  fi

  log "Booting emulator $AVD_NAME"
  "$emulator_bin" -avd "$AVD_NAME" -netdelay none -netspeed full \
    -no-boot-anim -no-snapshot-save \
    >"/tmp/$AVD_NAME.log" 2>&1 &

  trap 'log "Stopping emulator"; cleanup_emulator' EXIT

  wait_for_emulator
}

wait_for_emulator() {
  local adb
  adb="$(adb_path)"
  "$adb" start-server >/dev/null 2>&1
  log "Waiting for emulator to report as online"
  "$adb" wait-for-device
  until "$adb" shell getprop sys.boot_completed 2>/dev/null | grep -q "1"; do
    sleep 2
  done
  EMULATOR_SERIAL="$("$adb" devices | awk 'NR>1 && $2 == "device" {print $1; exit}')"
  if [[ -z "$EMULATOR_SERIAL" ]]; then
    log "Warning: could not automatically determine emulator serial; defaulting to emulator-5554"
    EMULATOR_SERIAL="emulator-5554"
  else
    log "Detected emulator serial $EMULATOR_SERIAL"
  fi
  log "Emulator booted"
}

boot_ios_simulator() {
  # Best-effort: prefer a named device if present, otherwise just open Simulator
  if command -v xcrun >/dev/null 2>&1; then
    if xcrun simctl list devices available | grep -q "$IOS_DEVICE_NAME"; then
      local udid
      udid="$(xcrun simctl list devices available | awk -v n="$IOS_DEVICE_NAME" '$0 ~ n " (.*) \(.*\) \(.*\)" {print $NF}' | tr -d '()' | head -n1)"
      if [[ -n "$udid" ]]; then
        log "Booting iOS Simulator: $IOS_DEVICE_NAME ($udid)"
        xcrun simctl boot "$udid" >/dev/null 2>&1 || true
      fi
    fi
  fi
  if ! open -a Simulator >/dev/null 2>&1; then
    # Fallback to absolute path if needed
    if [[ -e "/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app" ]]; then
      open -a "/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app" || true
    fi
  fi
}

install_and_run() {
  local target
  if [[ -n "$DEVICE_ID" ]]; then
    target="$DEVICE_ID"
  else
    if [[ "$PLATFORM" == "ios" ]]; then
      target="iOS"
    else
      # Default to first emulator serial if known; otherwise let Flutter pick
      target="${EMULATOR_SERIAL:-}"
    fi
  fi

  # If targeting macOS desktop but Xcode tools are unavailable, fall back to Chrome or web-server.
  if [[ "$target" == "macos" ]]; then
    if ! command -v xcrun >/dev/null 2>&1 || ! xcrun -f xcodebuild >/dev/null 2>&1; then
      if open -Ra "Google Chrome" >/dev/null 2>&1; then
        log "Xcode tools missing; falling back to Chrome device"
        target="chrome"
      else
        log "Xcode tools and Chrome unavailable; falling back to web-server device"
        target="web-server"
      fi
    fi
  fi

  if [[ -n "$target" ]]; then
    log "Starting Flutter app on device: $target"
    (cd "$PROJECT_ROOT" && flutter run -d "$target")
  else
    log "Starting Flutter app (no explicit device, letting Flutter choose)"
    (cd "$PROJECT_ROOT" && flutter run)
  fi
}

main() {
  local skip_build=false
  local skip_emulator=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --platform)
        if [[ -z "${2:-}" ]]; then
          log "--platform requires a value: ios | android | auto"
          exit 1
        fi
        PLATFORM="$2"
        shift 2
        ;;
      --device-id)
        if [[ -z "${2:-}" ]]; then
          log "--device-id requires a value (see 'flutter devices')"
          exit 1
        fi
        DEVICE_ID="$2"
        shift 2
        ;;
      --skip-build)
        skip_build=true
        shift
        ;;
      --skip-emulator)
        skip_emulator=true
        shift
        ;;
      --avd-name)
        if [[ -z "${2:-}" ]]; then
          log "--avd-name requires a value"
          exit 1
        fi
        AVD_NAME="$2"
        shift 2
        ;;
      --ios-device)
        if [[ -z "${2:-}" ]]; then
          log "--ios-device requires a value (e.g. 'iPhone 15')"
          exit 1
        fi
        IOS_DEVICE_NAME="$2"
        shift 2
        ;;
      --help|-h)
        usage
        exit 0
        ;;
      *)
        log "Unknown option: $1"
        usage
        exit 1
        ;;
    esac
  done

  require_flutter

  # Default to Google Chrome (web) when no explicit device is provided and
  # platform is auto-detected. If Chrome is unavailable, fall back to web-server.
  if [[ -z "$DEVICE_ID" && "$PLATFORM" == "auto" ]]; then
    if open -Ra "Google Chrome" >/dev/null 2>&1; then
      DEVICE_ID="chrome"
    else
      DEVICE_ID="web-server"
    fi
  fi

  # If a desktop/web device is explicitly targeted, skip simulator/emulator.
  if [[ -n "$DEVICE_ID" ]]; then
    case "$DEVICE_ID" in
      macos|linux|windows|chrome|edge|safari|web-server)
        skip_emulator=true
        ;;
    esac
  fi

  # Decide platform if auto
  if [[ "$PLATFORM" == "auto" && "$skip_emulator" != true ]]; then
    if command -v xcrun >/dev/null 2>&1; then
      PLATFORM="ios"
    elif [[ -d "$ANDROID_SDK_ROOT" ]]; then
      PLATFORM="android"
    else
      log "Unable to auto-detect platform. Provide --platform ios|android and ensure required tools are installed, or pass --device-id <desktop/web>."
      exit 1
    fi
  fi

  if [[ "$skip_build" != true ]]; then
    flutter_pub_get
  else
    log "Skipping flutter pub get by request"
  fi

  if [[ "$skip_emulator" == true ]]; then
    log "Simulator/emulator steps skipped"
  else
    if [[ "$PLATFORM" == "ios" ]]; then
      if ! ensure_ios_tools; then
        log "iOS tools not available; skipping iOS simulator boot"
      else
        boot_ios_simulator
      fi
    else
      ensure_android_sdk_config
      ensure_android_tools
      boot_emulator
    fi
  fi

  install_and_run
}

main "$@"
