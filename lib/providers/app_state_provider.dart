import 'package:flutter/material.dart';
import '../models/fish.dart';

/// Provider class for managing general app state
/// 
/// This provider handles:
/// - Current page navigation
/// - Currently viewed fish
/// - App loading states
/// - Recent activity tracking
class AppStateProvider extends ChangeNotifier {
  // Private fields
  int _currentPageIndex = 0;
  Fish? _currentlyViewedFish;
  bool _isAppLoading = false;
  String? _appError;
  final List<Fish> _recentlyViewedFish = [];
  final int _maxRecentItems = 10;

  // Navigation-related getters
  int get currentPageIndex => _currentPageIndex;
  
  // Fish-related getters
  Fish? get currentlyViewedFish => _currentlyViewedFish;
  List<Fish> get recentlyViewedFish => List.unmodifiable(_recentlyViewedFish);
  
  // App state getters
  bool get isAppLoading => _isAppLoading;
  String? get appError => _appError;

  /// Set the current page index
  void setCurrentPage(int pageIndex) {
    if (_currentPageIndex != pageIndex) {
      _currentPageIndex = pageIndex;
      notifyListeners();
    }
  }

  /// Set the currently viewed fish
  void setCurrentlyViewedFish(Fish? fish) {
    _currentlyViewedFish = fish;
    
    // Add to recently viewed if it's a new fish
    if (fish != null) {
      _addToRecentlyViewed(fish);
    }
    
    notifyListeners();
  }

  /// Navigate to a specific page
  void navigateToPage(int pageIndex) {
    setCurrentPage(pageIndex);
  }

  /// Navigate to home page
  void navigateToHome() {
    setCurrentPage(0);
  }

  /// Navigate to scanner page
  void navigateToScanner() {
    setCurrentPage(1);
  }

  /// Navigate to favorites page
  void navigateToFavorites() {
    setCurrentPage(2);
  }

  /// Navigate to library page
  void navigateToLibrary() {
    setCurrentPage(3);
  }

  /// Set app loading state
  void setAppLoading(bool loading) {
    _isAppLoading = loading;
    notifyListeners();
  }

  /// Set app error
  void setAppError(String? error) {
    _appError = error;
    notifyListeners();
  }

  /// Clear app error
  void clearAppError() {
    _appError = null;
    notifyListeners();
  }

  /// Add a fish to recently viewed list
  void _addToRecentlyViewed(Fish fish) {
    // Remove if already exists to avoid duplicates
    _recentlyViewedFish.removeWhere((f) => f.id == fish.id);
    
    // Add to the beginning of the list
    _recentlyViewedFish.insert(0, fish);
    
    // Keep only the most recent items
    if (_recentlyViewedFish.length > _maxRecentItems) {
      _recentlyViewedFish.removeRange(_maxRecentItems, _recentlyViewedFish.length);
    }
  }

  /// Clear recently viewed fish
  void clearRecentlyViewed() {
    _recentlyViewedFish.clear();
    notifyListeners();
  }

  /// Get recently viewed fish count
  int get recentlyViewedCount => _recentlyViewedFish.length;

  /// Check if a fish was recently viewed
  bool wasRecentlyViewed(String fishId) {
    return _recentlyViewedFish.any((fish) => fish.id == fishId);
  }

  /// Get the most recently viewed fish
  Fish? get mostRecentlyViewedFish {
    return _recentlyViewedFish.isNotEmpty ? _recentlyViewedFish.first : null;
  }

  /// Get page name by index
  String getPageName(int pageIndex) {
    switch (pageIndex) {
      case 0:
        return 'Home';
      case 1:
        return 'Scanner';
      case 2:
        return 'Favorites';
      case 3:
        return 'Library';
      default:
        return 'Unknown';
    }
  }

  /// Get current page name
  String get currentPageName => getPageName(_currentPageIndex);

  /// Check if currently on home page
  bool get isOnHomePage => _currentPageIndex == 0;

  /// Check if currently on scanner page
  bool get isOnScannerPage => _currentPageIndex == 1;

  /// Check if currently on favorites page
  bool get isOnFavoritesPage => _currentPageIndex == 2;

  /// Check if currently on library page
  bool get isOnLibraryPage => _currentPageIndex == 3;

  /// Reset app state (useful for logout or app restart)
  void resetAppState() {
    _currentPageIndex = 0;
    _currentlyViewedFish = null;
    _isAppLoading = false;
    _appError = null;
    _recentlyViewedFish.clear();
    notifyListeners();
  }

  /// Handle app initialization
  Future<void> initializeApp() async {
    setAppLoading(true);
    clearAppError();
    
    try {
      // Add any app initialization logic here
      // For example, checking app version, loading settings, etc.
      
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate loading
      
      print('App initialized successfully');
    } catch (e) {
      setAppError('Failed to initialize app: $e');
      print('Error initializing app: $e');
    } finally {
      setAppLoading(false);
    }
  }

  /// Handle deep linking or external navigation
  void handleDeepLink(String route, {Map<String, dynamic>? params}) {
    try {
      switch (route) {
        case '/home':
          navigateToHome();
          break;
        case '/scanner':
          navigateToScanner();
          break;
        case '/favorites':
          navigateToFavorites();
          break;
        case '/library':
          navigateToLibrary();
          break;
        case '/fish':
          if (params != null && params.containsKey('id')) {
            // This would need to be handled with the fish provider
            // to load the specific fish data
          }
          break;
        default:
          print('Unknown deep link route: $route');
      }
    } catch (e) {
      print('Error handling deep link: $e');
      setAppError('Failed to navigate to requested page');
    }
  }
}