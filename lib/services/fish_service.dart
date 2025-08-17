import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../database/database_helper.dart';
import '../models/fish.dart';
import '../utils/logger.dart';

/// Service class for fish-related operations
/// 
/// This class provides a clean interface for fish data operations,
/// abstracting away the database implementation details.
/// Supports both SQLite (mobile/desktop) and JSON (web) data sources.
class FishService {
  static final DatabaseHelper _db = DatabaseHelper.instance;
  static List<Fish>? _webFishCache;
  static bool _isWebDataLoaded = false;

  /// Load fish data from JSON assets (web platform)
  static Future<void> _loadWebFishData() async {
    if (_isWebDataLoaded && _webFishCache != null) {
      return;
    }

    try {
      Logger.info('Loading fish data from JSON for web platform...', 'FishService');
      
      final String jsonString = await rootBundle.loadString('assets/data/fish_database.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> fishList = jsonData['fish_database'] as List<dynamic>;
      
      _webFishCache = fishList.map((fishJson) => Fish.fromMap(fishJson as Map<String, dynamic>)).toList();
      _isWebDataLoaded = true;
      
      Logger.info('Loaded ${_webFishCache!.length} fish species from JSON', 'FishService');
    } catch (e) {
      Logger.error('Error loading web fish data: $e', 'FishService', e);
      _webFishCache = [];
      _isWebDataLoaded = false;
      rethrow;
    }
  }

  /// Get all fish from the appropriate data source
  static Future<List<Fish>> getAllFish() async {
    try {
      if (kIsWeb) {
        await _loadWebFishData();
        return List.from(_webFishCache ?? []);
      } else {
        return await _db.getAllFish();
      }
    } catch (e) {
      Logger.error('Error getting all fish: $e', 'FishService', e);
      return [];
    }
  }

  /// Get a specific fish by ID
  static Future<Fish?> getFishById(String id) async {
    try {
      if (kIsWeb) {
        await _loadWebFishData();
        try {
          return _webFishCache?.firstWhere((fish) => fish.id == id);
        } catch (e) {
          return null;
        }
      } else {
        return await _db.getFishById(id);
      }
    } catch (e) {
      Logger.error('Error getting fish by ID: $e', 'FishService', e);
      return null;
    }
  }

  /// Search fish by query (name, scientific name, aliases, etc.)
  static Future<List<Fish>> searchFish(String query) async {
    try {
      if (query.trim().isEmpty) {
        return await getAllFish();
      }
      
      if (kIsWeb) {
        await _loadWebFishData();
        final searchQuery = query.toLowerCase();
        return _webFishCache?.where((fish) {
          return fish.uniqueName.toLowerCase().contains(searchQuery) ||
                 fish.scientificName.toLowerCase().contains(searchQuery) ||
                 fish.description.toLowerCase().contains(searchQuery) ||
                 fish.japaneseNameRomaji.toLowerCase().contains(searchQuery) ||
                 fish.japaneseNameKanji.contains(query) ||
                 fish.commonAliases.any((alias) => alias.toLowerCase().contains(searchQuery));
        }).toList() ?? [];
      } else {
        return await _db.searchFish(query);
      }
    } catch (e) {
      Logger.error('Error searching fish: $e', 'FishService', e);
      return [];
    }
  }

  /// Get fish by habitat
  static Future<List<Fish>> getFishByHabitat(String habitat) async {
    try {
      if (kIsWeb) {
        await _loadWebFishData();
        final habitatQuery = habitat.toLowerCase();
        return _webFishCache?.where((fish) {
          return fish.habitats.any((h) => h.toLowerCase().contains(habitatQuery));
        }).toList() ?? [];
      } else {
        return await _db.getFishByHabitat(habitat);
      }
    } catch (e) {
      Logger.error('Error getting fish by habitat: $e', 'FishService', e);
      return [];
    }
  }

  /// Get fish by preparation method
  static Future<List<Fish>> getFishByPreparation(String preparation) async {
    try {
      if (kIsWeb) {
        await _loadWebFishData();
        final prepQuery = preparation.toLowerCase();
        return _webFishCache?.where((fish) {
          return fish.waysToEat.any((way) => way.toLowerCase().contains(prepQuery));
        }).toList() ?? [];
      } else {
        return await _db.getFishByPreparation(preparation);
      }
    } catch (e) {
      Logger.error('Error getting fish by preparation: $e', 'FishService', e);
      return [];
    }
  }

  /// Get fish that can be prepared as sushi/sashimi
  static Future<List<Fish>> getSushiFish() async {
    try {
      final allFish = await getAllFish();
      return allFish.where((fish) => 
        fish.waysToEat.any((way) => 
          way.toLowerCase().contains('sushi') || 
          way.toLowerCase().contains('sashimi') ||
          way.toLowerCase().contains('nigiri')
        )
      ).toList();
    } catch (e) {
      Logger.error('Error getting sushi fish: $e', 'FishService', e);
      return [];
    }
  }

  /// Get popular fish (first 10 alphabetically for now)
  static Future<List<Fish>> getPopularFish() async {
    try {
      final allFish = await getAllFish();
      return allFish.take(10).toList();
    } catch (e) {
      Logger.error('Error getting popular fish: $e', 'FishService', e);
      return [];
    }
  }

  /// Get fish by Japanese name (romaji or kanji)
  static Future<List<Fish>> getFishByJapaneseName(String japaneseName) async {
    try {
      final allFish = await getAllFish();
      return allFish.where((fish) =>
        fish.japaneseNameRomaji.toLowerCase().contains(japaneseName.toLowerCase()) ||
        fish.japaneseNameKanji.contains(japaneseName)
      ).toList();
    } catch (e) {
      Logger.error('Error getting fish by Japanese name: $e', 'FishService', e);
      return [];
    }
  }

  /// Get all unique habitats
  static Future<List<String>> getAllHabitats() async {
    try {
      final allFish = await getAllFish();
      final Set<String> habitats = {};
      
      for (final fish in allFish) {
        habitats.addAll(fish.habitats);
      }
      
      final List<String> sortedHabitats = habitats.toList();
      sortedHabitats.sort();
      return sortedHabitats;
    } catch (e) {
      Logger.error('Error getting all habitats: $e', 'FishService', e);
      return [];
    }
  }

  /// Get all unique preparation methods
  static Future<List<String>> getAllPreparations() async {
    try {
      final allFish = await getAllFish();
      final Set<String> preparations = {};
      
      for (final fish in allFish) {
        preparations.addAll(fish.waysToEat);
      }
      
      final List<String> sortedPreparations = preparations.toList();
      sortedPreparations.sort();
      return sortedPreparations;
    } catch (e) {
      Logger.error('Error getting all preparations: $e', 'FishService', e);
      return [];
    }
  }

  /// Get fish count
  static Future<int> getFishCount() async {
    try {
      if (kIsWeb) {
        await _loadWebFishData();
        return _webFishCache?.length ?? 0;
      } else {
        return await _db.getFishCount();
      }
    } catch (e) {
      Logger.error('Error getting fish count: $e', 'FishService', e);
      return 0;
    }
  }

  /// Check if database is initialized
  static Future<bool> isDatabaseInitialized() async {
    try {
      if (kIsWeb) {
        return _isWebDataLoaded && _webFishCache != null && _webFishCache!.isNotEmpty;
      } else {
        return await _db.isDatabaseInitialized();
      }
    } catch (e) {
      Logger.error('Error checking database initialization: $e', 'FishService', e);
      return false;
    }
  }

  /// Initialize database (mainly for first app launch)
  static Future<void> initializeDatabase() async {
    try {
      if (kIsWeb) {
        Logger.info('Initializing fish data for web platform...', 'FishService');
        await _loadWebFishData();
        Logger.info('Web fish data initialized with ${_webFishCache?.length ?? 0} species', 'FishService');
      } else {
        Logger.info('Initializing fish database for mobile/desktop...', 'FishService');
        
        // The database will be automatically initialized when first accessed
        // through the DatabaseHelper.instance.database getter
        final isInitialized = await isDatabaseInitialized();
        
        if (isInitialized) {
          final count = await getFishCount();
          Logger.info('Database already initialized with $count fish species', 'FishService');
        } else {
          Logger.info('Database not initialized, will be created on first access', 'FishService');
        }
      }
    } catch (e) {
      Logger.error('Error initializing database: $e', 'FishService', e);
      rethrow;
    }
  }

  /// Reinitialize database (for development/testing)
  static Future<void> reinitializeDatabase() async {
    try {
      await _db.reinitializeDatabase();
      Logger.info('Database reinitialized successfully', 'FishService');
    } catch (e) {
      Logger.error('Error reinitializing database: $e', 'FishService', e);
      rethrow;
    }
  }

  /// Add a new fish (for future admin functionality)
  static Future<bool> addFish(Fish fish) async {
    try {
      final result = await _db.insertFish(fish);
      return result > 0;
    } catch (e) {
      Logger.error('Error adding fish: $e', 'FishService', e);
      return false;
    }
  }

  /// Update an existing fish (for future admin functionality)
  static Future<bool> updateFish(Fish fish) async {
    try {
      final result = await _db.updateFish(fish);
      return result > 0;
    } catch (e) {
      Logger.error('Error updating fish: $e', 'FishService', e);
      return false;
    }
  }

  /// Delete a fish (for future admin functionality)
  static Future<bool> deleteFish(String id) async {
    try {
      final result = await _db.deleteFish(id);
      return result > 0;
    } catch (e) {
      Logger.error('Error deleting fish: $e', 'FishService', e);
      return false;
    }
  }

  /// Get random fish for discovery
  static Future<List<Fish>> getRandomFish({int count = 5}) async {
    try {
      final allFish = await getAllFish();
      if (allFish.length <= count) {
        return allFish;
      }
      
      allFish.shuffle();
      return allFish.take(count).toList();
    } catch (e) {
      Logger.error('Error getting random fish: $e', 'FishService', e);
      return [];
    }
  }

  /// Close database connection
  static Future<void> close() async {
    try {
      await _db.close();
    } catch (e) {
      Logger.error('Error closing database: $e', 'FishService', e);
    }
  }
}