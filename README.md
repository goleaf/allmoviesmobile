# AllMovies Mobile

AllMovies is an Android client for browsing movie information from [TMDB](https://www.themoviedb.org/). The project is written in Kotlin and follows an MVVM architecture with Jetpack components.

This repository now includes a macOS-friendly automation script that lets you run every build, test, and deployment task from the Cursor editor without opening Android Studio. The README provides the full manual process so you can reproduce the workflow or adapt it to your own setup.

## Features

- Smooth loading indicators while browsing movie collections and details.
- Full-text movie search with instant results.
- Navigation drawer with access to Home and About.
- Language selection dialog for switching between supported locales.
- Actor detail pages linked from each movie's cast list.

## Technology stack

- Kotlin with Coroutines, Serialization, and ViewBinding
- Android Jetpack: ViewModel, LiveData, Room, RecyclerView
- Networking via Retrofit and OkHttp
- Image loading with Glide

## Prerequisites

Before running the automation script or manual steps, make sure the following tools are available on your macOS machine:

1. **Java Development Kit 17** (Gradle 7.3.3 does not support bytecode produced by newer JDKs such as 20 or 21).
2. **Android command-line tools** installed under `~/Library/Android/sdk` (the default path used by the script).
3. **Required Android packages** installed through `sdkmanager`, for example:
   ```bash
   sdkmanager \
     "platform-tools" \
     "emulator" \
     "platforms;android-34" \
     "system-images;android-34;google_apis;x86_64"
   ```
4. **An Android Virtual Device (AVD)** created with `avdmanager`, e.g.:
   ```bash
   avdmanager create avd \
     --name allmovies_pixel_5_api_34 \
     --package "system-images;android-34;google_apis;x86_64" \
     --device "pixel_5"
   ```
5. **Gradle wrapper dependencies** (downloaded automatically during the first build).

> **API key note:** The project looks for a TMDB API key in `local.properties` under the key `apiKey`. If the file is absent the demo key bundled with the project is used. To supply your own key, create `local.properties` in the project root containing `apiKey=<YOUR_KEY>`.

## Running every task from Cursor on macOS

The `macos_cursor_runner.sh` script orchestrates the workflow for you: it runs the Gradle tasks, boots the emulator, installs the generated APK, and launches the application. Run it directly from the project root.

```bash
./macos_cursor_runner.sh
```

By default the script executes the following Gradle tasks in order: `clean`, `lint`, `testDebugUnitTest`, and `assembleDebug`. When these tasks complete, the script boots the AVD named `allmovies_pixel_5_api_34`, waits for Android to finish booting, installs `app-debug.apk`, and starts the `dev.tutushkin.allmovies` package via `adb`. The script automatically detects the running emulator serial and tears it down on exit so repeated runs stay clean.

### Script options

- `--skip-build`: Skip the Gradle tasks (useful if you already have a fresh APK).
- `--skip-emulator`: Run only the Gradle tasks.
- `--avd-name <name>`: Override the default AVD name without changing the environment variable.

You can also set environment variables before running the script:

```bash
export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
export AVD_NAME="my_custom_avd"
./macos_cursor_runner.sh --skip-build
```

The script validates that both `adb` and the `emulator` binary are available. If either check fails, install or correct the Android SDK path before rerunning the script.

## Manual workflow without Android Studio

If you prefer to execute the steps manually, follow this guide:

1. **Build and test the project**
   ```bash
   ./gradlew clean lint testDebugUnitTest assembleDebug
   ```
   The generated debug APK will be located at `app/build/outputs/apk/debug/app-debug.apk`.

2. **Start an emulator from the command line**
   ```bash
   "$ANDROID_SDK_ROOT/emulator/emulator" \
     -avd allmovies_pixel_5_api_34 \
     -netdelay none -netspeed full \
     -no-boot-anim -no-snapshot-save
   ```
   Wait until `adb shell getprop sys.boot_completed` prints `1` to confirm the boot process has finished.

3. **Install and launch the app**
   ```bash
   adb install -r app/build/outputs/apk/debug/app-debug.apk
   adb shell monkey -p dev.tutushkin.allmovies \
     -c android.intent.category.LAUNCHER 1
   ```

4. **Stop the emulator (optional)**
   ```bash
   adb emu kill
   ```

## Troubleshooting

- **`adb` or `emulator` not found:** Ensure `ANDROID_SDK_ROOT` points to the directory containing `platform-tools` and `emulator`.
- **Gradle build failures:** Verify that you are using JDK 17 (newer JDKs lead to `Unsupported class file major version` errors with this Gradle version) and that you have an active internet connection to download dependencies during the first build.
- **API key errors:** Double-check `local.properties` for typos and confirm that your TMDB API key is valid.

## Localization verification

The language picker now relies entirely on localized string resources. To confirm the behaviour manually on a device or emulator:

1. Launch the app and open the overflow menu.
2. Tap **Language** and choose **Русский**; the dialog title and menu entry should immediately render in Russian.
3. Dismiss and reopen the menu to verify every action title uses the selected locale.
4. Repeat the steps selecting **English** to switch back.

An instrumentation test suite (`LanguageResourcesInstrumentedTest`) also exercises the localized resources for the dialog labels. Run it with `./gradlew connectedAndroidTest` when an emulator is attached.

## Screenshots

![Movie list screenshot](https://github.com/sergeytutushkin/AllMovies/blob/master/app/src/main/res/drawable/screenshot_list.webp?raw=true)
![Movie details screenshot](https://github.com/sergeytutushkin/AllMovies/blob/master/app/src/main/res/drawable/screenshot_details.webp?raw=true)

## License

This project follows the licensing terms defined by the upstream AllMovies repository.
