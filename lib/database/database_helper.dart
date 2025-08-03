import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/fish.dart';

/// Database helper class for managing SQLite operations
/// 
/// This class handles:
/// - Database creation and schema management
/// - Initial data loading from JSON assets
/// - CRUD operations for fish data
/// - Search and filtering functionality
class DatabaseHelper {
  static const String _databaseName = 'gyo_gai_do.db';
  static const int _databaseVersion = 1;
  
  // Table names
  static const String fishTable = 'fish';
  
  // Fish table columns
  static const String columnId = 'id';
  static const String columnUniqueName = 'unique_name';
  static const String columnDescription = 'description';
  static const String columnCommonAliases = 'common_aliases';
  static const String columnScientificName = 'scientific_name';
  static const String columnJapaneseNameRomaji = 'japanese_name_romaji';
  static const String columnJapaneseNameKanji = 'japanese_name_kanji';
  static const String columnLifespan = 'lifespan';
  static const String columnSize = 'size';
  static const String columnWeight = 'weight';
  static const String columnHabitats = 'habitats';
  static const String columnWaysToEat = 'ways_to_eat';
  static const String columnSushiImages = 'sushi_images';
  static const String columnWildImages = 'wild_images';
  static const String columnHabitatMapImage = 'habitat_map_image';

  // Singleton pattern
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  /// Get database instance, creating it if it doesn't exist
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initialize the database
  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), _databaseName);
    
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    print('Creating database tables...');
    
    await db.execute('''
      CREATE TABLE $fishTable (
        $columnId TEXT PRIMARY KEY,
        $columnUniqueName TEXT NOT NULL,
        $columnDescription TEXT NOT NULL,
        $columnCommonAliases TEXT NOT NULL,
        $columnScientificName TEXT NOT NULL,
        $columnJapaneseNameRomaji TEXT NOT NULL,
        $columnJapaneseNameKanji TEXT NOT NULL,
        $columnLifespan TEXT NOT NULL,
        $columnSize TEXT NOT NULL,
        $columnWeight TEXT NOT NULL,
        $columnHabitats TEXT NOT NULL,
        $columnWaysToEat TEXT NOT NULL,
        $columnSushiImages TEXT NOT NULL,
        $columnWildImages TEXT NOT NULL,
        $columnHabitatMapImage TEXT NOT NULL
      )
    ''');

    // Create indexes for search performance
    await db.execute('''
      CREATE INDEX idx_fish_name ON $fishTable($columnUniqueName)
    ''');
    
    await db.execute('''
      CREATE INDEX idx_fish_scientific ON $fishTable($columnScientificName)
    ''');

    print('Database tables created successfully');
    
    // Load initial data
    await _loadInitialData(db);
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('Upgrading database from version $oldVersion to $newVersion');
    
    // Handle future database migrations here
    if (oldVersion < 2) {
      // Example: Add new columns or tables
    }
  }

  /// Load initial fish data from JSON assets
  Future<void> _loadInitialData(Database db) async {
    print('Loading initial fish data from assets...');
    
    try {
      // Load JSON data from assets
      final String jsonString = await rootBundle.loadString('assets/data/fish_database.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> fishList = jsonData['fish_database'] as List<dynamic>;
      
      print('Found ${fishList.length} fish species in JSON');
      
      // Insert each fish into the database
      final Batch batch = db.batch();
      int insertCount = 0;
      
      for (final dynamic fishJson in fishList) {
        try {
          final Fish fish = Fish.fromMap(fishJson as Map<String, dynamic>);
          batch.insert(fishTable, _fishToDbMap(fish));
          insertCount++;
        } catch (e) {
          print('Error inserting fish: $e');
        }
      }
      
      await batch.commit(noResult: true);
      print('Successfully inserted $insertCount fish species into database');
      
    } catch (e) {
      print('Error loading initial data: $e');
      rethrow;
    }
  }

  /// Convert Fish object to database map format
  Map<String, dynamic> _fishToDbMap(Fish fish) {
    return {
      columnId: fish.id,
      columnUniqueName: fish.uniqueName,
      columnDescription: fish.description,
      columnCommonAliases: json.encode(fish.commonAliases),
      columnScientificName: fish.scientificName,
      columnJapaneseNameRomaji: fish.japaneseNameRomaji,
      columnJapaneseNameKanji: fish.japaneseNameKanji,
      columnLifespan: fish.lifespan,
      columnSize: fish.size,
      columnWeight: fish.weight,
      columnHabitats: json.encode(fish.habitats),
      columnWaysToEat: json.encode(fish.waysToEat),
      columnSushiImages: json.encode(fish.sushiImages),
      columnWildImages: json.encode(fish.wildImages),
      columnHabitatMapImage: fish.habitatMapImage,
    };
  }

  /// Convert database map to Fish object
  Fish _dbMapToFish(Map<String, dynamic> map) {
    return Fish(
      id: map[columnId] as String,
      uniqueName: map[columnUniqueName] as String,
      description: map[columnDescription] as String,
      commonAliases: List<String>.from(json.decode(map[columnCommonAliases] as String)),
      scientificName: map[columnScientificName] as String,
      japaneseNameRomaji: map[columnJapaneseNameRomaji] as String,
      japaneseNameKanji: map[columnJapaneseNameKanji] as String,
      lifespan: map[columnLifespan] as String,
      size: map[columnSize] as String,
      weight: map[columnWeight] as String,
      habitats: List<String>.from(json.decode(map[columnHabitats] as String)),
      waysToEat: List<String>.from(json.decode(map[columnWaysToEat] as String)),
      sushiImages: List<String>.from(json.decode(map[columnSushiImages] as String)),
      wildImages: List<String>.from(json.decode(map[columnWildImages] as String)),
      habitatMapImage: map[columnHabitatMapImage] as String,
    );
  }

  /// Get all fish from the database
  Future<List<Fish>> getAllFish() async {
    final Database db = await database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      fishTable,
      orderBy: '$columnUniqueName ASC',
    );
    
    return maps.map((map) => _dbMapToFish(map)).toList();
  }

  /// Get a fish by ID
  Future<Fish?> getFishById(String id) async {
    final Database db = await database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      fishTable,
      where: '$columnId = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (maps.isNotEmpty) {
      return _dbMapToFish(maps.first);
    }
    
    return null;
  }

  /// Search fish by name, scientific name, or aliases
  Future<List<Fish>> searchFish(String query) async {
    if (query.trim().isEmpty) {
      return getAllFish();
    }
    
    final Database db = await database;
    final String searchQuery = '%${query.toLowerCase()}%';
    
    final List<Map<String, dynamic>> maps = await db.query(
      fishTable,
      where: '''
        LOWER($columnUniqueName) LIKE ? OR 
        LOWER($columnScientificName) LIKE ? OR 
        LOWER($columnDescription) LIKE ? OR
        LOWER($columnJapaneseNameRomaji) LIKE ? OR
        $columnJapaneseNameKanji LIKE ? OR
        LOWER($columnCommonAliases) LIKE ?
      ''',
      whereArgs: [searchQuery, searchQuery, searchQuery, searchQuery, query, searchQuery],
      orderBy: '$columnUniqueName ASC',
    );
    
    return maps.map((map) => _dbMapToFish(map)).toList();
  }

  /// Get fish by habitat
  Future<List<Fish>> getFishByHabitat(String habitat) async {
    final Database db = await database;
    final String habitatQuery = '%${habitat.toLowerCase()}%';
    
    final List<Map<String, dynamic>> maps = await db.query(
      fishTable,
      where: 'LOWER($columnHabitats) LIKE ?',
      whereArgs: [habitatQuery],
      orderBy: '$columnUniqueName ASC',
    );
    
    return maps.map((map) => _dbMapToFish(map)).toList();
  }

  /// Get fish by preparation method
  Future<List<Fish>> getFishByPreparation(String preparation) async {
    final Database db = await database;
    final String prepQuery = '%${preparation.toLowerCase()}%';
    
    final List<Map<String, dynamic>> maps = await db.query(
      fishTable,
      where: 'LOWER($columnWaysToEat) LIKE ?',
      whereArgs: [prepQuery],
      orderBy: '$columnUniqueName ASC',
    );
    
    return maps.map((map) => _dbMapToFish(map)).toList();
  }

  /// Insert a new fish
  Future<int> insertFish(Fish fish) async {
    final Database db = await database;
    
    return await db.insert(
      fishTable,
      _fishToDbMap(fish),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update an existing fish
  Future<int> updateFish(Fish fish) async {
    final Database db = await database;
    
    return await db.update(
      fishTable,
      _fishToDbMap(fish),
      where: '$columnId = ?',
      whereArgs: [fish.id],
    );
  }

  /// Delete a fish
  Future<int> deleteFish(String id) async {
    final Database db = await database;
    
    return await db.delete(
      fishTable,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  /// Get count of all fish
  Future<int> getFishCount() async {
    final Database db = await database;
    
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $fishTable'
    );
    
    return result.first['count'] as int;
  }

  /// Check if database is properly initialized with data
  Future<bool> isDatabaseInitialized() async {
    try {
      final int count = await getFishCount();
      return count > 0;
    } catch (e) {
      return false;
    }
  }

  /// Reinitialize database (for development/testing)
  Future<void> reinitializeDatabase() async {
    print('Reinitializing database...');
    
    final String path = join(await getDatabasesPath(), _databaseName);
    
    // Close existing database
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    
    // Delete database file
    await deleteDatabase(path);
    
    // Recreate database
    _database = await _initDatabase();
    
    print('Database reinitialized successfully');
  }

  /// Close the database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}