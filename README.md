# CTIS Dictionary

A Flutter application for managing and browsing dictionary entries for CTIS (Computer Technology and Information Systems) topics.

## Features

- Browse and search through various CTIS topics
- Create new topics and entries
- Profile settings with dark mode support
- Modern and responsive UI

## Prerequisites

Before you begin, ensure you have the following installed:

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Dart SDK](https://dart.dev/get-dart)
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/) with Flutter extensions
- An Android emulator or physical device for testing

## Getting Started

1. **Clone the repository**

   ```bash
   git clone [your-repository-url]
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
│   └── theme_provider.dart
├── screens/              # Application screens
│   ├── home_screen.dart
│   ├── profile_screen.dart
│   ├── topic_create_screen.dart
│   └── topic_entries_screen.dart
└── widgets/              # Reusable widgets
    └── topic_card.dart
```

## Dependencies

The project uses the following main dependencies:

- `provider: ^6.1.1` - For state management
- `flutter/material.dart` - For UI components
- `cupertino_icons: ^1.0.2` - For iOS-style icons

## Features in Detail

### Home Screen

- Displays a list of CTIS topics
- Add new topics using the floating action button
- Access profile settings via the profile icon in the app bar

### Profile Screen

- View and edit user profile
- Toggle dark mode
- Manage notifications and language settings
- Logout functionality

### Topic Management

- Create new topics
- View topic entries
- Update topic information

## Theme Support

The application supports both light and dark themes:

- Light theme: Default theme with a red accent color (0xFF8E272A)
- Dark theme: Dark variant of the same color scheme
- Theme can be toggled from the profile screen

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
