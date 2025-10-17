# Project Cleanup: Remove Laravel, keep Android app only

Priority order:
1. Create tasks files and commit plan
2. Remove Laravel root files and directories
3. Remove Laravel subdirectories from the Android `app` module
4. Verify Android project structure remains intact
5. Attempt Android assembleDebug build (skippable in environments without Android SDK)

Tasks
- Create and commit todo.md with cleanup plan
- Remove Laravel root files and directories
- Remove Laravel subdirectories inside app module
- Ensure Android project structure remains intact
- Attempt Android assembleDebug build to verify

Notes
- Remove all Laravel-specific files: Root: `artisan`, `bootstrap/`, `composer.json`, `composer.lock`, `config/`, `database/`, `public/`, `resources/`, `routes/`, `storage/`, `phpunit.xml`, `tests/`, `vendor/`; inside `app/`: `Console/`, `Exceptions/`, `Http/`, `Livewire/`, `Mail/`, `Models/`, `Providers/`, `Services/`.
- Preserve Android files: Root: `build.gradle`, `settings.gradle`, `gradle/`, `gradlew`, `gradlew.bat`, `local.properties`; Module: `app/build.gradle`, `app/src/**`, `app/proguard-rules.pro`, `app/build/**`.
