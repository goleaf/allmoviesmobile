#!/bin/bash
set -euo pipefail

# macos_cursor_runner.sh
# -----------------------
# Helper script intended for macOS developers working in Cursor to build, test,
# and deploy the AllMovies Android application to a command-line Android
# emulator. The script keeps the steps deterministic and documents the
# prerequisites so you can run the project without installing the full Android
# Studio IDE.

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GRADLEW="$PROJECT_ROOT/gradlew"
ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$HOME/Library/Android/sdk}"
AVD_NAME="${AVD_NAME:-allmovies_pixel_5_api_34}"
APK_PATH="$PROJECT_ROOT/app/build/outputs/apk/debug/app-debug.apk"
PACKAGE_NAME="dev.tutushkin.allmovies"
EMULATOR_SERIAL=""

GRADLE_TASKS=(
  clean
  lint
  testDebugUnitTest
  assembleDebug
)

usage() {
  cat <<USAGE
Usage: $0 [--skip-build] [--skip-emulator] [--avd-name <name>]

Options:
  --skip-build       Skip Gradle tasks (useful if you only want to deploy).
  --skip-emulator    Do not start or interact with the Android emulator.
  --avd-name <name>  Override the Android Virtual Device name to boot.

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

run_gradle_tasks() {
  require_file "$GRADLEW"
  chmod +x "$GRADLEW"
  for task in "${GRADLE_TASKS[@]}"; do
    log "Running ./gradlew $task"
    (cd "$PROJECT_ROOT" && "$GRADLEW" "$task")
  done
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

install_and_run() {
  local adb target_args
  adb="$(adb_path)"
  if [[ -n "$EMULATOR_SERIAL" ]]; then
    target_args=("-s" "$EMULATOR_SERIAL")
  else
    target_args=()
  fi

  if [[ ! -f "$APK_PATH" ]]; then
    log "APK not found at $APK_PATH"
    log "Did you run the Gradle build tasks?"
    exit 1
  fi

  log "Installing APK"
  "$adb" "${target_args[@]}" install -r "$APK_PATH"

  log "Launching $PACKAGE_NAME"
  "$adb" "${target_args[@]}" shell monkey -p "$PACKAGE_NAME" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1
  log "Application launch command dispatched"
}

main() {
  local skip_build=false
  local skip_emulator=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
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

  if [[ "$skip_build" != true ]]; then
    run_gradle_tasks
  else
    log "Skipping Gradle tasks by request"
  fi

  if [[ "$skip_emulator" == true ]]; then
    log "Emulator steps skipped"
    exit 0
  fi

  ensure_android_tools
  boot_emulator
  install_and_run
}

main "$@"
