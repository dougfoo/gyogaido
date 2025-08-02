# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Gyo Gai Do (魚外道) is a Flutter mobile application that helps users identify fish species through camera scanning. The app is designed as a "Gaijin Guide to Gyo (Fish)" - a learning tool for fish identification and information.

## Development Commands

### Core Flutter Commands
- `flutter run` - Run the app in development mode
- `flutter build apk` - Build APK for Android
- `flutter build ios` - Build for iOS (requires macOS)
- `flutter build web` - Build for web deployment
- `flutter test` - Run all tests
- `flutter analyze` - Run static analysis (uses flutter_lints ruleset)
- `flutter pub get` - Install dependencies
- `flutter pub upgrade` - Upgrade dependencies
- `flutter clean` - Clean build artifacts

### Testing
- `flutter test test/hello_world_test.dart` - Run specific test file
- Tests are located in the `test/` directory

## Architecture Overview

### Main Application Structure
- **Entry Point**: `lib/main.dart` - Contains GyoGaiDoApp and MyHomePage with PageView navigation
- **Core Pages**: 4-page tab navigation system using PageController:
  1. Home screen - Welcome/info page
  2. Fish Scanner - Camera functionality (lib/fish_cam.dart)
  3. Favorites - Saved fish (lib/fish_views.dart)
  4. Library - Browse all fish (lib/fish_views.dart)

### Key Components
- **FishCard**: `lib/fish_card.dart` - Reusable card component for displaying fish information with different sizes (small/medium/large) and detail views
- **FishScanner**: `lib/fish_cam.dart` - Camera integration for fish identification (uses image_picker, has placeholder for Google Vision API)
- **Navigation**: Bottom navigation bar with floating action button for quick scanner access

### Dependencies
- `flutter_dotenv` - Environment variable management (.env support)
- `font_awesome_flutter` - Icon library
- `image_picker` - Camera/gallery image selection
- `url_launcher` - External link opening
- `http` - HTTP requests
- `flutter_lints` - Dart/Flutter linting rules

### Platform Support
- Android, iOS, Web, Linux, macOS, Windows
- Cross-platform image handling with kIsWeb conditional logic
- Assets stored in `assets/images/` directory

### Development Notes
- Uses Material 3 design system
- Custom color scheme with orange/brown seed color
- Environment loading commented out in main.dart (line 8)
- Google Vision API integration partially implemented but commented out
- Fish data is currently hardcoded/placeholder - real fish database not yet implemented