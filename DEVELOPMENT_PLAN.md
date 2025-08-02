# 🐟 Gyo Gai Do Development Plan

## Project Overview
Transform the current Flutter app skeleton into a fully functional fish identification app that helps users identify fish species through camera scanning and provides comprehensive information about each species.

## Current State Analysis

### ✅ Implemented Features
- Basic 4-page navigation structure 
- UI scaffolding for all main screens
- FishCard component with detailed view
- Image picker integration
- Basic theming and icons

### ❌ Missing Core Features
- Fish database/data models
- Actual fish identification logic
- Favorites persistence 
- Real fish data (currently all placeholder)
- Google Vision API integration
- State management
- Offline support

## Technical Architecture

### Fish Data Model
```dart
class Fish {
  String id;                    // Local database primary key
  String uniqueName;
  String description;
  List<String> commonAliases;
  String scientificName;
  String japaneseNameRomaji;
  String japaneseNameKanji;
  String lifespan;
  String size;
  String weight;
  List<String> habitats;
  List<String> waysToEat;
  
  // Local asset paths
  List<String> sushiImagePaths;
  List<String> wildImagePaths;
  String habitatMapImagePath;
}
```

### Storage Strategy - Local Device Storage
- **Primary Storage: SQLite** - Local database using sqflite for fish data
- **Image Storage: Local Assets** - Fish images bundled with app in assets/
- **User Data: SharedPreferences** - Store favorites and app settings locally

### Fish Identification Strategy
**Phase 1 - MVP Approach:**
- Use Google Vision API for general image classification
- Manual fish database matching against detected labels
- Confidence scoring system
- Fallback to "Unknown fish" with manual identification request

**Phase 2 - Enhanced Recognition:**
- Custom TensorFlow Lite model for fish-specific recognition
- Integration with FishBase API for species data
- User feedback loop to improve accuracy

### Favorites System
- SharedPreferences for favorite fish IDs list
- Local database table for favorites with timestamp
- Export/import functionality for user data
- Heart icon toggle on FishCards
- "Recently viewed" section

## Development Roadmap

## Phase 1: Foundation (Weeks 1-3)
### Core Infrastructure
1. **Local Database & Fish Data Model**
   - Create Fish model class with local storage properties
   - Implement SQLite database with sqflite
   - Create database service layer for CRUD operations
   - Bundle initial fish dataset (10-15 common species) with app assets

2. **State Management**
   - Add Provider or Riverpod for app state
   - Implement FishService for data operations
   - Create FavoritesService for persistence

3. **Fix Current Issues**
   - Fix scroll navigation in PageView (`main.dart:13`)
   - Update help icon to info icon (`main.dart:14`)
   - Fix text wrapping in FishCard details (`fish_card.dart:163`)
   - Add loading states and error handling

### Dependencies to Add
```yaml
dependencies:
  # Local storage
  sqflite: ^2.3.0
  path: ^1.8.3
  
  # State management
  provider: ^6.1.1
  shared_preferences: ^2.2.2
```

## Phase 2: Core Features (Weeks 4-6)
### Fish Identification System
1. **Google Vision API Integration**
   - Complete API setup and authentication
   - Implement image analysis pipeline in `fish_cam.dart`
   - Add confidence scoring and result ranking
   - Create fallback handling for unknown fish

2. **Favorites System**
   - Add heart toggle buttons to FishCards
   - Implement favorites persistence
   - Update Favorites screen with real data
   - Add recently viewed section

### Enhanced UI/UX
1. **Search & Filter**
   - Add search bar to Library screen
   - Implement filtering by habitat, size, type
   - Add sort options (alphabetical, size, etc.)

2. **Camera Experience**
   - Improve camera preview and capture flow
   - Add processing indicators and feedback
   - Implement image quality suggestions

### Additional Dependencies
```yaml
dependencies:
  googleapis: ^14.0.0
  googleapis_auth: ^2.2.0
```

## Phase 3: Content & Polish (Weeks 7-9)
### Database Population
1. **Expand Fish Dataset**
   - Research and add 40+ more species
   - Source high-quality images for all fish
   - Add comprehensive Japanese names and cultural info
   - Create habitat maps and distribution data

2. **Content Quality**
   - Validate all scientific information
   - Add cooking methods and cultural context
   - Include seasonal availability information

### Advanced Features
1. **Offline Support**
   - Implement offline-first architecture
   - Add sync capabilities for future cloud integration
   - Cache images and data locally

2. **Performance Optimization**
   - Optimize image loading and caching
   - Implement lazy loading for large lists
   - Add progressive image loading

### Target Fish Species (Initial 50)
**Common Sushi Fish:**
- Tuna (Bluefin, Yellowfin, Bigeye)
- Salmon (Atlantic, Chinook, Coho)
- Yellowtail (Hamachi)
- Sea Bream (Tai)
- Mackerel (Saba)
- Eel (Unagi, Anago)
- Sea Bass (Suzuki)
- Flounder (Hirame)
- Squid (Ika)
- Octopus (Tako)

**Popular Japanese Fish:**
- Horse Mackerel (Aji)
- Sardine (Iwashi)
- Saury (Sanma)
- Red Snapper (Madai)
- Amberjack (Kanpachi)

## Phase 4: Testing & Release (Weeks 10-12)
### Comprehensive Testing
1. **Test Coverage**
   - Unit tests for all models and services
   - Widget tests for components
   - Integration tests for key user flows
   - Performance testing

2. **User Testing**
   - Beta testing with target users
   - Gather feedback on accuracy and usability
   - Iterate based on user feedback

### Testing Strategy
- **Unit Tests**: Fish model, database operations, API services
- **Widget Tests**: FishCard components, navigation, favorites functionality  
- **Integration Tests**: Camera flow, fish identification pipeline
- **Golden Tests**: UI consistency across different screen sizes
- **Performance Tests**: Image processing, database queries

### Release Preparation
1. **Platform Optimization**
   - Android/iOS specific optimizations
   - App store assets and descriptions
   - Privacy policy and terms of service

2. **Documentation**
   - User guide and help documentation
   - Developer documentation updates
   - Release notes and changelog

## UI/UX Improvements Needed

### Current Issues (from code comments)
- Scroll left navigation not working properly (`main.dart:13`)
- Help icon should become info icon (`main.dart:14`) 
- Text wrapping issues in FishCard (`fish_card.dart:163`)
- Add favorites toggle button (`fish_card.dart:7`)

### Additional UX Enhancements
- Loading states for camera and API calls
- Error handling and user feedback
- Search functionality in Library
- Filter/sort options (by habitat, size, etc.)
- Offline mode indicators
- Camera preview and capture feedback
- Progressive image loading with placeholders

## Future Enhancements (Post-MVP)
- **Cloud Storage & Sync**: Firebase/Firestore for real-time updates and user data sync
- **Community Features**: User-submitted fish photos, ratings, and reviews
- **Advanced Analytics**: Usage tracking and fish identification accuracy metrics
- Custom ML model for fish-specific recognition
- Social features (sharing catches, community ID)
- Integration with fishing/sushi restaurant databases
- Augmented reality features
- Multi-language support beyond Japanese
- Fish preparation and cooking guides
- Seasonal availability notifications
- Integration with fishing regulations/licenses

## Development Best Practices
- Follow existing code style and conventions
- Use flutter_lints for code quality
- Implement proper error handling throughout
- Add comprehensive logging for debugging
- Ensure cross-platform compatibility
- Optimize for performance on lower-end devices
- Implement proper state management patterns
- Use dependency injection for testability

## Resources & References
- [FishBase.org](https://fishbase.org) - Scientific fish database
- [Google Vision API Documentation](https://cloud.google.com/vision/docs)
- [Flutter State Management Guide](https://docs.flutter.dev/development/data-and-backend/state-mgmt)
- [SQLite Flutter Plugin](https://pub.dev/packages/sqflite)
- Japanese fish name resources and cultural context materials