# CTIS Dictionary

A Flutter application for managing and browsing dictionary entries for CTIS (Computer Technology and Information Systems) topics.

## Features

- Browse and search through various CTIS topics
- Create new topics and entries
- User authentication with Google Sign-In
- Profile settings with dark mode support
- Modern and responsive UI
- Real-time data synchronization with Firebase
- Offline data persistence

## Prerequisites

Before you begin, ensure you have the following installed:

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Dart SDK](https://dart.dev/get-dart)
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/) with Flutter extensions
- An Android emulator or physical device for testing
- Firebase account and project setup

## Getting Started

1. **Clone the repository**

   ```bash
   git clone https://github.com/Baturalp52/CTIS-470-project
   cd ctis_dictionary
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Run the application**

   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart              # Application entry point
├── models/               # Data models
├── providers/            # State management providers
│   ├── theme_provider.dart
│   └── auth_provider.dart
├── screens/              # Application screens
│   ├── home_screen.dart
│   ├── profile_screen.dart
│   ├── topic_create_screen.dart
│   └── topic_entries_screen.dart
├── services/            # Firebase and other services
│   ├── auth_service.dart
│   └── firestore_service.dart
├── utils/              # Utility functions and constants
└── widgets/            # Reusable widgets
    └── topic_card.dart
```

## Dependencies

The project uses the following main dependencies:

- `provider: ^6.1.1` - For state management
- `firebase_core: ^3.13.0` - Firebase core functionality
- `firebase_auth: ^5.5.2` - Firebase authentication
- `cloud_firestore: ^5.6.6` - Firebase Cloud Firestore
- `shared_preferences: ^2.2.2` - Local storage
- `google_sign_in: ^6.1.6` - Google Sign-In integration
- `flutter/material.dart` - For UI components
- `cupertino_icons: ^1.0.2` - For iOS-style icons

## Features in Detail

### Authentication

- Google Sign-In integration
- User profile management
- Secure authentication flow

### Home Screen

- Displays a list of CTIS topics
- Add new topics using the floating action button
- Access profile settings via the profile icon in the app bar
- Real-time updates of topics

### Profile Screen

- View and edit user profile
- Toggle dark mode
- Manage notifications and language settings
- Logout functionality

### Topic Management

- Create new topics
- View topic entries
- Update topic information
- Real-time synchronization with Firebase

## Theme Support

The application supports both light and dark themes:

- Light theme: Default theme with a red accent color (0xFF8E272A)
- Dark theme: Dark variant of the same color scheme
- Theme can be toggled from the profile screen
- Theme preference is persisted using SharedPreferences

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
