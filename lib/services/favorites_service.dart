import 'package:shared_preferences/shared_preferences.dart';
import '../models/fish.dart';
import 'fish_service.dart';
import '../utils/logger.dart';

/// Service class for managing user's favorite fish
/// 
/// This class handles persistence of favorite fish using SharedPreferences
/// and provides methods to add, remove, and retrieve favorites.
class FavoritesService {
  static const String _favoritesKey = 'favorite_fish_ids';

  /// Get the list of favorite fish IDs
  static Future<Set<String>> getFavoriteIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> favoriteIds = prefs.getStringList(_favoritesKey) ?? [];
      return favoriteIds.toSet();
    } catch (e) {
      Logger.error('Error getting favorite IDs: $e', 'FavoritesService', e);
      return {};
    }
  }

  /// Check if a fish is in favorites
  static Future<bool> isFavorite(String fishId) async {
    try {
      final favoriteIds = await getFavoriteIds();
      return favoriteIds.contains(fishId);
    } catch (e) {
      Logger.error('Error checking if fish is favorite: $e', 'FavoritesService', e);
      return false;
    }
  }

  /// Add a fish to favorites
  static Future<bool> addToFavorites(String fishId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoriteIds = await getFavoriteIds();
      
      if (!favoriteIds.contains(fishId)) {
        favoriteIds.add(fishId);
        final success = await prefs.setStringList(_favoritesKey, favoriteIds.toList());
        
        if (success) {
          Logger.info('Added fish $fishId to favorites', 'FavoritesService');
          return true;
        }
      }
      
      return false;
    } catch (e) {
      Logger.error('Error adding fish to favorites: $e', 'FavoritesService', e);
      return false;
    }
  }

  /// Remove a fish from favorites
  static Future<bool> removeFromFavorites(String fishId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoriteIds = await getFavoriteIds();
      
      if (favoriteIds.contains(fishId)) {
        favoriteIds.remove(fishId);
        final success = await prefs.setStringList(_favoritesKey, favoriteIds.toList());
        
        if (success) {
          Logger.info('Removed fish $fishId from favorites', 'FavoritesService');
          return true;
        }
      }
      
      return false;
    } catch (e) {
      Logger.error('Error removing fish from favorites: $e', 'FavoritesService', e);
      return false;
    }
  }

  /// Toggle favorite status for a fish
  static Future<bool> toggleFavorite(String fishId) async {
    try {
      final isCurrentlyFavorite = await isFavorite(fishId);
      
      if (isCurrentlyFavorite) {
        return await removeFromFavorites(fishId);
      } else {
        return await addToFavorites(fishId);
      }
    } catch (e) {
      Logger.error('Error toggling favorite: $e', 'FavoritesService', e);
      return false;
    }
  }

  /// Get all favorite fish objects
  static Future<List<Fish>> getFavoriteFish() async {
    try {
      final favoriteIds = await getFavoriteIds();
      
      if (favoriteIds.isEmpty) {
        return [];
      }

      final List<Fish> favoriteFish = [];
      
      for (final fishId in favoriteIds) {
        final fish = await FishService.getFishById(fishId);
        if (fish != null) {
          favoriteFish.add(fish);
        }
      }
      
      // Sort alphabetically by name
      favoriteFish.sort((a, b) => a.uniqueName.compareTo(b.uniqueName));
      
      return favoriteFish;
    } catch (e) {
      Logger.error('Error getting favorite fish: $e', 'FavoritesService', e);
      return [];
    }
  }

  /// Get count of favorite fish
  static Future<int> getFavoriteCount() async {
    try {
      final favoriteIds = await getFavoriteIds();
      return favoriteIds.length;
    } catch (e) {
      Logger.error('Error getting favorite count: $e', 'FavoritesService', e);
      return 0;
    }
  }

  /// Clear all favorites
  static Future<bool> clearAllFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.remove(_favoritesKey);
      
      if (success) {
        Logger.info('Cleared all favorites', 'FavoritesService');
      }
      
      return success;
    } catch (e) {
      Logger.error('Error clearing favorites: $e', 'FavoritesService', e);
      return false;
    }
  }

  /// Export favorites as a list of fish IDs
  static Future<List<String>> exportFavorites() async {
    try {
      final favoriteIds = await getFavoriteIds();
      return favoriteIds.toList();
    } catch (e) {
      Logger.error('Error exporting favorites: $e', 'FavoritesService', e);
      return [];
    }
  }

  /// Import favorites from a list of fish IDs
  static Future<bool> importFavorites(List<String> fishIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Validate that all fish IDs exist
      final validIds = <String>[];
      for (final fishId in fishIds) {
        final fish = await FishService.getFishById(fishId);
        if (fish != null) {
          validIds.add(fishId);
        }
      }
      
      final success = await prefs.setStringList(_favoritesKey, validIds);
      
      if (success) {
        Logger.info('Imported ${validIds.length} favorites (${fishIds.length - validIds.length} invalid IDs skipped)', 'FavoritesService');
      }
      
      return success;
    } catch (e) {
      Logger.error('Error importing favorites: $e', 'FavoritesService', e);
      return false;
    }
  }

  /// Add multiple fish to favorites at once
  static Future<int> addMultipleToFavorites(List<String> fishIds) async {
    try {
      int addedCount = 0;
      
      for (final fishId in fishIds) {
        final added = await addToFavorites(fishId);
        if (added) {
          addedCount++;
        }
      }
      
      return addedCount;
    } catch (e) {
      Logger.error('Error adding multiple to favorites: $e', 'FavoritesService', e);
      return 0;
    }
  }

  /// Get recently added favorites (last N added)
  static Future<List<Fish>> getRecentlyAddedFavorites({int limit = 5}) async {
    try {
      // Note: SharedPreferences doesn't maintain order,
      // so this is a simplified implementation
      // In a production app, you might want to store timestamps
      final favoriteFish = await getFavoriteFish();
      
      // Return last N fish (or all if less than N)
      if (favoriteFish.length <= limit) {
        return favoriteFish;
      }
      
      return favoriteFish.sublist(favoriteFish.length - limit);
    } catch (e) {
      Logger.error('Error getting recently added favorites: $e', 'FavoritesService', e);
      return [];
    }
  }
}