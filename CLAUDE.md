# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter pub get                                              # install dependencies
dart run build_runner build --delete-conflicting-outputs    # regenerate DI code (after adding @injectable)
flutter analyze                                             # static analysis (must pass clean)
dart format lib                                             # format (CI enforces this)
flutter test                                               # all tests
flutter test test/path/to/file_test.dart                   # single test file
flutter run                                                # run on connected device/emulator
flutter build web --release                                # web build (used in CI)
```

## Architecture

Clean Architecture organized by feature. Each feature under `lib/features/<name>/` has up to three layers:

- `domain/` — pure Dart: entities, repository interfaces, use cases. No Flutter, no Firebase.
- `data/` — implements domain repository contracts (Firebase calls live here).
- `presentation/` — BLoC + pages + widgets.

`lib/core/` is shared infrastructure: DI (`di/`), error types (`error/`), router (`router/`), theme (`theme/`), global widgets (`widgets/`).

**Dependency rule:** `presentation` → `domain` ← `data`. Never `presentation` → `data` directly.

## Key Patterns

**Error handling:** Use cases return `Either<Failure, T>` (from `dartz`). Call `.fold(onFailure, onSuccess)` at the BLoC layer — never leak `Failure` into presentation.

**BLoC:** UI dispatches Events → BLoC emits States. States: `AuthInitial`, `AuthLoading`, `AuthAuthenticated`, `AuthUnauthenticated`, `AuthError`. Auth BLoC subscribes to `authRepository.authStateChanges` stream on init.

**Routing:** `GoRouter` with a `redirect` guard in `app_router.dart` that reads `AuthBloc` state. Unauthenticated users are always pushed to `/sign-in`. Authenticated pages live inside a `ShellRoute` that renders `AppShell` (bottom nav).

**DI:** `GetIt` + `injectable`. Annotate classes with `@injectable` or `@lazySingleton`, then regenerate with `build_runner`. Entry point: `configureDependencies()` called in `main()`.

## Adding a New Feature

1. Create `lib/features/<name>/domain/` with entity, repository interface, and use cases.
2. Create `lib/features/<name>/data/repositories/<name>_repository_impl.dart`.
3. Create `lib/features/<name>/presentation/bloc/` (event, state, bloc files) and `pages/`.
4. Register the page route in `lib/core/router/app_router.dart` and add the path constant to `app_routes.dart`.

## CI

GitHub Actions runs on push to `main`/`develop` and PRs to `main`: `flutter analyze` (must be clean) → `flutter test` → `flutter build web`. SonarCloud runs separately via `sonar.yml`.
