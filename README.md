# Sentinel App 

Sentinel is a comprehensive mobile application built with **Flutter** designed for monitoring and managing the well-being of the elderly. This application acts as a companion interface to the Sentinel system, offering real-time camera statuses, event logs, elderly profile management, and instant push notifications for critical alerts.

## Features

- **Authentication System**: Secure Login and Registration pages (`auth_pages`).
- **Elderly Profile Management**: Add, view, edit, and list profiles for elderly individuals under care.
- **Camera Integration**: Check real-time statuses and views of monitoring cameras.
- **Event Tracking**: Monitor events, alerts, and logs for occurrences detected by the system.
- **Push & Local Notifications**: Integrated with Firebase Cloud Messaging (FCM) and `flutter_local_notifications` to provide instant background and foreground alerts.
- **Modern UI**: Clean and intuitive navigation using a bottom navbar structure.

## Technology Stack

- **Framework**: [Flutter](https://flutter.dev/) (Dart)
- **Backend / API**: HTTP requests to the Sentinel Backend API (`http` package).
- **Notifications**: 
  - `firebase_messaging` (Push Notifications)
  - `flutter_local_notifications` (Local alerts)
- **State & Local Storage**: `shared_preferences`
- **Other Utilities**: `cupertino_icons`, `flutter_native_splash`, `flutter_launcher_icons`

## Folder Structure

The application's logic is primarily contained within the `lib/` directory:

```text
lib/
├── auth_pages/         # Login and Registration screens
├── navbar/             # Main navigation views (Camera, Elderly List, Events, Profile)
├── pages/              # Additional pages (Home, Add/Edit/Detail Elderly)
├── services/           # Core API & Notification services (FCM, Local Notifications, HTTP service)
├── firebase_options.dart # Firebase configuration
└── main.dart           # Application entry point and route definitions
```

## Getting Started

### Prerequisites
Before you begin, ensure you have met the following requirements:
* You have installed the latest stable version of [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.12.1 or higher recommended).
* You have a working emulator or a physical device connected.
* (Optional) Access to the Firebase Console if you need to update/configure Push Notifications.

### Installation

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd sentinel_new_app
   ```

2. **Install dependencies:**
   Fetch the necessary Flutter packages.
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration:**
   The project is configured to use Firebase. Ensure that valid `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS) are placed in their respective directories (`android/app/` and `ios/Runner/`) if you are deploying to a new environment, or use the existing configuration.

4. **Run the App:**
   ```bash
   flutter run
   ```

## Build and Deployment

### Android
To generate an APK or App Bundle for Android:
```bash
# For APK
flutter build apk --release

# For App Bundle
flutter build appbundle --release
```

### iOS
To generate an IPA for iOS (requires macOS and Xcode):
```bash
flutter build ipa --release
```

## 🤝 Contributing
Contributions, issues, and feature requests are welcome! Feel free to check the issues page if you want to contribute.

## 📝 License
This project is proprietary and confidential.
