# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Install dependencies
flutter pub get

# Run the app (debug)
flutter run

# Build release APK
flutter build apk --release

# Run tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Analyze for lint/type issues
flutter analyze
```

CI runs `flutter build apk --release` on every push to `main` using Flutter 3.27.0 / Java 17.

## Architecture

Pixple is a Flutter food-allergy detection app targeting Android. It is locked to portrait orientation.

### Navigation model

`MainShell` in [main.dart](air-file://tevmnkqlh694qfpeb6q1/D:/projects/pixple/pixple/lib/main.dart?type=file&root=D%3A) owns a single `StateProvider<NavTab>` (Riverpod) that drives which top-level screen is shown. Screens are swapped via a `switch` expression — there is no `Navigator` stack at the shell level. Each screen receives `currentTab` and `onTabSelected` callbacks and renders its own `BottomNavBar`. The `NavTab` enum has four values (`allergy`, `recipe`, `leftover`, `community`), but `recipe` and `leftover` tabs are currently commented out of the nav bar.

### Allergy detection flow

`AllergyScreen` → `AllergyApi.detect()` → backend → `AllergyResultScreen`

The image is base64-encoded on device and POSTed to `https://pixple-backend.vercel.app/api/gemini-api` along with the prompt from [Prompts.dart](air-file://tevmnkqlh694qfpeb6q1/D:/projects/pixple/pixple/lib/utils/Prompts.dart?type=file&root=D%3A). The backend calls Gemini and returns `{ code, cached, data: { allergens: string[] } }`. Allergen names are always Korean strings (e.g. `"계란"`, `"우유"`). The mapping from Korean names to display metadata lives in [allergen_map.dart](air-file://tevmnkqlh694qfpeb6q1/D:/projects/pixple/pixple/lib/data/allergen_map.dart?type=file&root=D%3A).

### Community feature

`CommunityApi` is a static-method class hitting `pixple-backend.vercel.app/api/community/*`. User identity is anonymous and persistent: `LocalIdentity` generates a UUID v4 on first launch and stores it via `shared_preferences`. The same UUID is used as `user_id` for authoring and deleting articles/comments. Delete permission checks happen server-side by comparing `user_id`.

### State management

Riverpod (`flutter_riverpod`) is used only at the navigation level (`_currentTabProvider` in `main.dart`). All other state is local `StatefulWidget` / `setState`. There are no `Provider`s, `Notifier`s, or `AsyncNotifier`s beyond that one `StateProvider`.

### Theming

All colors are defined as `const` values on `AppColors` in [app_theme.dart](air-file://tevmnkqlh694qfpeb6q1/D:/projects/pixple/pixple/lib/theme/app_theme.dart?type=file&root=D%3A). The app font is **Jua** (Google Fonts). Always use `AppColors.*` constants instead of raw `Color(...)` literals.

### Shared base widget

`_CameraBaseScreen` in [camera_screens.dart](air-file://tevmnkqlh694qfpeb6q1/D:/projects/pixple/pixple/lib/screens/camera_screens.dart?type=file&root=D%3A) is the layout shell for `AllergyScreen`, `RecipeScreen`, and `LeftoverScreen`. It renders the title, subtitle, `PhotoPickerButton`, `BottomNavBar`, and end-drawer. Only `AllergyScreen` wires up both `onPhotoTap` and `onGalleryTap`; the recipe/leftover screens only wire `onPhotoTap`.

### Backend

All API calls go to `pixple-backend.vercel.app`. There is no local backend — the project is purely client + hosted backend. The Gemini prompt is defined entirely in the Flutter app ([Prompts.dart](air-file://tevmnkqlh694qfpeb6q1/D:/projects/pixple/pixple/lib/utils/Prompts.dart?type=file&root=D%3A)) and forwarded by the backend proxy.
