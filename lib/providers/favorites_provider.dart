import 'package:flutter/material.dart';
import '../models/fish.dart';
import '../services/favorites_service.dart';

/// Provider class for managing favorite fish state
/// 
/// This provider handles:
/// - Adding and removing fish from favorites
/// - Loading favorite fish data
/// - Checking favorite status
/// - Syncing with SharedPreferences storage
class FavoritesProvider extends ChangeNotifier {
  // Private fields
  Set<String> _favoriteIds = {};
  List<Fish> _favoriteFish = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  Set<String> get favoriteIds => _favoriteIds;
  List<Fish> get favoriteFish => _favoriteFish;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get favoriteCount => _favoriteIds.length;

  /// Check if a fish is in favorites
  bool isFavorite(String fishId) {
    return _favoriteIds.contains(fishId);
  }

  /// Load all favorite data
  Future<void> loadFavorites() async {
    _setLoading(true);
    _clearError();

    try {
      // Load favorite IDs
      _favoriteIds = await FavoritesService.getFavoriteIds();
      
      // Load favorite fish objects
      _favoriteFish = await FavoritesService.getFavoriteFish();
      
      print('Loaded ${_favoriteIds.length} favorite fish');
    } catch (e) {
      _setError('Failed to load favorites: $e');
      print('Error loading favorites: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Add a fish to favorites
  Future<bool> addToFavorites(String fishId) async {
    try {
      final success = await FavoritesService.addToFavorites(fishId);
      
      if (success) {
        _favoriteIds.add(fishId);
        // Reload favorite fish to get the updated list
        await _reloadFavoriteFish();
        notifyListeners();
        print('Added fish $fishId to favorites');
      }
      
      return success;
    } catch (e) {
      _setError('Failed to add to favorites: $e');
      print('Error adding to favorites: $e');
      return false;
    }
  }

  /// Remove a fish from favorites
  Future<bool> removeFromFavorites(String fishId) async {
    try {
      final success = await FavoritesService.removeFromFavorites(fishId);
      
      if (success) {
        _favoriteIds.remove(fishId);
        // Remove from favorite fish list
        _favoriteFish.removeWhere((fish) => fish.id == fishId);
        notifyListeners();
        print('Removed fish $fishId from favorites');
      }
      
      return success;
    } catch (e) {
      _setError('Failed to remove from favorites: $e');
      print('Error removing from favorites: $e');
      return false;
    }
  }

  /// Toggle favorite status for a fish
  Future<bool> toggleFavorite(String fishId) async {
    if (isFavorite(fishId)) {
      return await removeFromFavorites(fishId);
    } else {
      return await addToFavorites(fishId);
    }
  }

  /// Add a Fish object to favorites (convenience method)
  Future<bool> addFishToFavorites(Fish fish) async {
    return await addToFavorites(fish.id);
  }

  /// Remove a Fish object from favorites (convenience method)
  Future<bool> removeFishFromFavorites(Fish fish) async {
    return await removeFromFavorites(fish.id);
  }

  /// Toggle favorite status for a Fish object (convenience method)
  Future<bool> toggleFishFavorite(Fish fish) async {
    return await toggleFavorite(fish.id);
  }

  /// Get recently added favorites
  Future<List<Fish>> getRecentlyAddedFavorites({int limit = 5}) async {
    try {
      return await FavoritesService.getRecentlyAddedFavorites(limit: limit);
    } catch (e) {
      _setError('Failed to get recent favorites: $e');
      print('Error getting recent favorites: $e');
      return [];
    }
  }

  /// Clear all favorites
  Future<bool> clearAllFavorites() async {
    try {
      final success = await FavoritesService.clearAllFavorites();
      
      if (success) {
        _favoriteIds.clear();
        _favoriteFish.clear();
        notifyListeners();
        print('Cleared all favorites');
      }
      
      return success;
    } catch (e) {
      _setError('Failed to clear favorites: $e');
      print('Error clearing favorites: $e');
      return false;
    }
  }

  /// Export favorites as a list of fish IDs
  Future<List<String>> exportFavorites() async {
    try {
      return await FavoritesService.exportFavorites();
    } catch (e) {
      _setError('Failed to export favorites: $e');
      print('Error exporting favorites: $e');
      return [];
    }
  }

  /// Import favorites from a list of fish IDs
  Future<bool> importFavorites(List<String> fishIds) async {
    try {
      final success = await FavoritesService.importFavorites(fishIds);
      
      if (success) {
        // Reload favorites to reflect the imported data
        await loadFavorites();
        print('Imported favorites successfully');
      }
      
      return success;
    } catch (e) {
      _setError('Failed to import favorites: $e');
      print('Error importing favorites: $e');
      return false;
    }
  }

  /// Add multiple fish to favorites at once
  Future<int> addMultipleToFavorites(List<String> fishIds) async {
    try {
      final addedCount = await FavoritesService.addMultipleToFavorites(fishIds);
      
      if (addedCount > 0) {
        // Reload favorites to reflect the changes
        await loadFavorites();
        print('Added $addedCount fish to favorites');
      }
      
      return addedCount;
    } catch (e) {
      _setError('Failed to add multiple favorites: $e');
      print('Error adding multiple favorites: $e');
      return 0;
    }
  }

  /// Get fish that are similar to favorited fish (based on habitat/preparation)
  List<Fish> getSimilarToFavorites(List<Fish> allFish) {
    if (_favoriteFish.isEmpty) {
      return [];
    }

    final Set<String> favoriteHabitats = {};
    final Set<String> favoritePreparations = {};
    
    // Collect habitats and preparations from favorite fish
    for (final fish in _favoriteFish) {
      favoriteHabitats.addAll(fish.habitats);
      favoritePreparations.addAll(fish.waysToEat);
    }

    // Find fish that share habitats or preparations with favorites
    final similar = allFish.where((fish) =>
      !isFavorite(fish.id) && // Not already a favorite
      (fish.habitats.any((habitat) => favoriteHabitats.contains(habitat)) ||
       fish.waysToEat.any((prep) => favoritePreparations.contains(prep)))
    ).toList();

    return similar;
  }

  /// Check if there are any favorites
  bool get hasFavorites => _favoriteIds.isNotEmpty;

  /// Refresh all favorite data
  Future<void> refresh() async {
    await loadFavorites();
  }

  /// Initialize the provider
  Future<void> initialize() async {
    await loadFavorites();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  /// Reload favorite fish objects from service
  Future<void> _reloadFavoriteFish() async {
    try {
      _favoriteFish = await FavoritesService.getFavoriteFish();
    } catch (e) {
      print('Error reloading favorite fish: $e');
    }
  }
}