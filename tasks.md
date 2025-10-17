# Tasks

Objective: Remove Laravel; keep only Android mobile app

Checklist
- [ ] Create and commit todo.md and tasks.md
- [ ] Remove Laravel root files and directories
- [ ] Remove Laravel subdirectories inside `app/`
- [ ] Verify Android project structure remains intact
- [ ] Attempt Android assembleDebug build (skip if Android SDK unavailable)

Deletions (Laravel):
- Root: `artisan`, `bootstrap/`, `composer.json`, `composer.lock`, `config/`, `database/`, `public/`, `resources/`, `routes/`, `storage/`, `phpunit.xml`, `tests/`, `vendor/`
- Inside `app/`: `Console/`, `Exceptions/`, `Http/`, `Livewire/`, `Mail/`, `Models/`, `Providers/`, `Services/`

Preserve (Android):
- Root: `build.gradle`, `settings.gradle`, `gradle/`, `gradlew`, `gradlew.bat`, `local.properties`
- Module: `app/build.gradle`, `app/src/**`, `app/proguard-rules.pro`, `app/build/**`

