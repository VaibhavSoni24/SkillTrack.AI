# SkillTrack.AI Frontend (Flutter)

SkillTrack.AI is an AI-powered skill tracking and portfolio platform. This repository contains the Flutter client app used for web and mobile experiences.

## Highlights

- Authentication flows (login, signup, protected routing)
- Dashboard with skill and activity insights
- Activity logging and history
- Skill tracking and progression views
- Project management and portfolio generation
- Resume generation and export flows
- Public profile pages
- App settings and theme mode support

## Tech Stack

- Flutter (Dart SDK 3.10+)
- State management: Riverpod + Flutter Hooks
- Navigation: go_router
- Networking: Dio
- Secure token storage: flutter_secure_storage
- Charts and UI polish: fl_chart, flutter_animate, shimmer
- Monitoring and analytics: Sentry, PostHog

## Project Structure

```
lib/
	core/
		config/       # constants + environment config
		network/      # API client, endpoints, exceptions
		theme/        # app color system and themes
		utils/
	features/
		activities/
		auth/
		dashboard/
		portfolio/
		profile/
		projects/
		resume/
		settings/
		skills/
	routes/         # go_router setup and route guards
	shared/         # shared widgets/components
	main.dart       # app bootstrap + ProviderScope + Sentry init
```

## Requirements

- Flutter SDK installed and available in PATH
- Dart SDK 3.10.8+ (managed by Flutter)
- Android Studio and/or Xcode (for platform builds)

## Quick Start

1. Install dependencies:

```bash
flutter pub get
```

2. Run on your target platform:

```bash
# Mobile/Desktop
flutter run

# Web
flutter run -d chrome
```

## Environment Configuration

Environment values are provided at compile time using --dart-define.

Defined keys:

- API_BASE_URL (default: https://api.skilltrack.ai)
- APP_URL (default: https://app.skilltrack.ai)
- SENTRY_DSN (empty disables Sentry)
- POSTHOG_API_KEY (empty disables analytics)
- POSTHOG_HOST (default: https://app.posthog.com)
- GITHUB_CLIENT_ID
- GOOGLE_CLIENT_ID
- LINKEDIN_CLIENT_ID
- MAX_FILE_SIZE (default: 10485760)

Example run command:

```bash
flutter run -d chrome \
	--dart-define=API_BASE_URL=https://api.skilltrack.ai \
	--dart-define=APP_URL=https://app.skilltrack.ai \
	--dart-define=SENTRY_DSN= \
	--dart-define=POSTHOG_API_KEY=
```

## Quality Checks

Run analyzer:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

## Build

Web build:

```bash
flutter build web \
	--release \
	--dart-define=API_BASE_URL=https://api.skilltrack.ai \
	--dart-define=APP_URL=https://app.skilltrack.ai
```

Android APK:

```bash
flutter build apk --release
```

iOS (macOS only):

```bash
flutter build ios --release
```

## Routing and Auth Behavior

- Unauthenticated users are redirected to /login.
- Authenticated users are redirected away from auth pages to /.
- Public profiles under /u/:username are accessible without auth.

## Architecture Notes

- API calls are centralized in a Dio-based client with token refresh handling.
- Access and refresh tokens are persisted securely.
- Router guards are driven by auth state from Riverpod.
- Sentry is initialized only when SENTRY_DSN is provided.

For broader production and infrastructure context, see DOCUMENTATION.md.
