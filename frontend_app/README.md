# Trendix

A Flutter mobile application for tracking trends across platforms.

## Supported Platforms

- **Android** (API 21+)
- **iOS** (iOS 12.0+)

## Getting Started

### Prerequisites
- Flutter SDK (3.9.0 or higher)
- Android Studio / Xcode for respective platform development
- Android SDK for Android development
- Xcode for iOS development

### Installation

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. For Android: `flutter run`
4. For iOS: `flutter run` (requires macOS and Xcode)

### Build Commands

```bash
# Android APK
flutter build apk

# Android App Bundle
flutter build appbundle

# iOS (requires macOS)
flutter build ios
```

## Deployment

### Production API 
To run the app against the live API instead of local, modify `EnvironmentConfig` in `lib/config/environment.dart` or simply run the app with the specific environments defined via `--dart-define`.

### Generate Production Release (Android)
To automatically clean, fetch, and build the release Android App Bundle (AAB), simply run:
```bash
build_production.bat
```
Then upload `build/app/outputs/bundle/release/app-release.aab` to the Google Play Console securely.
