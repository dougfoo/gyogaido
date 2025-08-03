import '../database/database_helper.dart';
import '../models/fish.dart';

/// Service class for fish-related operations
/// 
/// This class provides a clean interface for fish data operations,
/// abstracting away the database implementation details.
class FishService {
  static final DatabaseHelper _db = DatabaseHelper.instance;

  /// Get all fish from the database
  static Future<List<Fish>> getAllFish() async {
    try {
      return await _db.getAllFish();
    } catch (e) {
      print('Error getting all fish: $e');
      return [];
    }
  }

  /// Get a specific fish by ID
  static Future<Fish?> getFishById(String id) async {
    try {
      return await _db.getFishById(id);
    } catch (e) {
      print('Error getting fish by ID: $e');
      return null;
    }
  }

  /// Search fish by query (name, scientific name, aliases, etc.)
  static Future<List<Fish>> searchFish(String query) async {
    try {
      if (query.trim().isEmpty) {
        return await getAllFish();
      }
      return await _db.searchFish(query);
    } catch (e) {
      print('Error searching fish: $e');
      return [];
    }
  }

  /// Get fish by habitat
  static Future<List<Fish>> getFishByHabitat(String habitat) async {
    try {
      return await _db.getFishByHabitat(habitat);
    } catch (e) {
      print('Error getting fish by habitat: $e');
      return [];
    }
  }

  /// Get fish by preparation method
  static Future<List<Fish>> getFishByPreparation(String preparation) async {
    try {
      return await _db.getFishByPreparation(preparation);
    } catch (e) {
      print('Error getting fish by preparation: $e');
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
      print('Error getting sushi fish: $e');
      return [];
    }
  }

  /// Get popular fish (first 10 alphabetically for now)
  static Future<List<Fish>> getPopularFish() async {
    try {
      final allFish = await getAllFish();
      return allFish.take(10).toList();
    } catch (e) {
      print('Error getting popular fish: $e');
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
      print('Error getting fish by Japanese name: $e');
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
      print('Error getting all habitats: $e');
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
      print('Error getting all preparations: $e');
      return [];
    }
  }

  /// Get fish count
  static Future<int> getFishCount() async {
    try {
      return await _db.getFishCount();
    } catch (e) {
      print('Error getting fish count: $e');
      return 0;
    }
  }

  /// Check if database is initialized
  static Future<bool> isDatabaseInitialized() async {
    try {
      return await _db.isDatabaseInitialized();
    } catch (e) {
      print('Error checking database initialization: $e');
      return false;
    }
  }

  /// Initialize database (mainly for first app launch)
  static Future<void> initializeDatabase() async {
    try {
      print('Initializing fish database...');
      
      // The database will be automatically initialized when first accessed
      // through the DatabaseHelper.instance.database getter
      final isInitialized = await isDatabaseInitialized();
      
      if (isInitialized) {
        final count = await getFishCount();
        print('Database already initialized with $count fish species');
      } else {
        print('Database not initialized, will be created on first access');
      }
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }

  /// Reinitialize database (for development/testing)
  static Future<void> reinitializeDatabase() async {
    try {
      await _db.reinitializeDatabase();
      print('Database reinitialized successfully');
    } catch (e) {
      print('Error reinitializing database: $e');
      rethrow;
    }
  }

  /// Add a new fish (for future admin functionality)
  static Future<bool> addFish(Fish fish) async {
    try {
      final result = await _db.insertFish(fish);
      return result > 0;
    } catch (e) {
      print('Error adding fish: $e');
      return false;
    }
  }

  /// Update an existing fish (for future admin functionality)
  static Future<bool> updateFish(Fish fish) async {
    try {
      final result = await _db.updateFish(fish);
      return result > 0;
    } catch (e) {
      print('Error updating fish: $e');
      return false;
    }
  }

  /// Delete a fish (for future admin functionality)
  static Future<bool> deleteFish(String id) async {
    try {
      final result = await _db.deleteFish(id);
      return result > 0;
    } catch (e) {
      print('Error deleting fish: $e');
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
      print('Error getting random fish: $e');
      return [];
    }
  }

  /// Close database connection
  static Future<void> close() async {
    try {
      await _db.close();
    } catch (e) {
      print('Error closing database: $e');
    }
  }
}