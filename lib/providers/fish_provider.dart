import 'package:flutter/material.dart';
import '../models/fish.dart';
import '../services/fish_service.dart';
import '../utils/logger.dart';

/// Provider class for managing fish data state
/// 
/// This provider handles:
/// - Loading fish data from the database
/// - Search functionality
/// - Filtering by habitat and preparation
/// - Loading states and error handling
class FishProvider extends ChangeNotifier {
  // Private fields
  List<Fish> _allFish = [];
  List<Fish> _filteredFish = [];
  List<Fish> _searchResults = [];
  bool _isLoading = false;
  String? _error;
  String _currentSearchQuery = '';
  String? _currentHabitatFilter;
  String? _currentPreparationFilter;

  // Getters
  List<Fish> get allFish => _allFish;
  List<Fish> get filteredFish => _filteredFish;
  List<Fish> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentSearchQuery => _currentSearchQuery;
  String? get currentHabitatFilter => _currentHabitatFilter;
  String? get currentPreparationFilter => _currentPreparationFilter;
  
  /// Get the currently displayed fish list based on search/filter state
  List<Fish> get displayedFish {
    if (_currentSearchQuery.isNotEmpty) {
      return _searchResults;
    } else if (_currentHabitatFilter != null || _currentPreparationFilter != null) {
      return _filteredFish;
    } else {
      return _allFish;
    }
  }

  /// Check if any filters are active
  bool get hasActiveFilters {
    return _currentSearchQuery.isNotEmpty || 
           _currentHabitatFilter != null || 
           _currentPreparationFilter != null;
  }

  /// Load all fish data from the database
  Future<void> loadAllFish() async {
    _setLoading(true);
    _clearError();

    try {
      _allFish = await FishService.getAllFish();
      _filteredFish = List.from(_allFish);
      _searchResults = List.from(_allFish);
      
      Logger.info('Loaded ${_allFish.length} fish species', 'FishProvider');
    } catch (e) {
      _setError('Failed to load fish data: $e');
      Logger.error('Error loading fish: $e', 'FishProvider', e);
    } finally {
      _setLoading(false);
    }
  }

  /// Search fish by query
  Future<void> searchFish(String query) async {
    _currentSearchQuery = query.trim();
    
    if (_currentSearchQuery.isEmpty) {
      _searchResults = List.from(_allFish);
      notifyListeners();
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      _searchResults = await FishService.searchFish(_currentSearchQuery);
      Logger.info('Found ${_searchResults.length} fish matching "$_currentSearchQuery"', 'FishProvider');
    } catch (e) {
      _setError('Search failed: $e');
      Logger.error('Error searching fish: $e', 'FishProvider', e);
    } finally {
      _setLoading(false);
    }
  }

  /// Filter fish by habitat
  Future<void> filterByHabitat(String? habitat) async {
    _currentHabitatFilter = habitat;
    await _applyFilters();
  }

  /// Filter fish by preparation method
  Future<void> filterByPreparation(String? preparation) async {
    _currentPreparationFilter = preparation;
    await _applyFilters();
  }

  /// Apply current filters
  Future<void> _applyFilters() async {
    _setLoading(true);
    _clearError();

    try {
      List<Fish> filtered = List.from(_allFish);

      // Apply habitat filter
      if (_currentHabitatFilter != null && _currentHabitatFilter!.isNotEmpty) {
        filtered = await FishService.getFishByHabitat(_currentHabitatFilter!);
      }

      // Apply preparation filter (intersect with existing filtered list)
      if (_currentPreparationFilter != null && _currentPreparationFilter!.isNotEmpty) {
        final preparationFiltered = await FishService.getFishByPreparation(_currentPreparationFilter!);
        
        if (_currentHabitatFilter != null && _currentHabitatFilter!.isNotEmpty) {
          // Intersect the two filtered lists
          filtered = filtered.where((fish) => 
            preparationFiltered.any((prepFish) => prepFish.id == fish.id)
          ).toList();
        } else {
          filtered = preparationFiltered;
        }
      }

      _filteredFish = filtered;
      Logger.info('Applied filters: ${_filteredFish.length} fish remaining', 'FishProvider');
    } catch (e) {
      _setError('Filter failed: $e');
      Logger.error('Error applying filters: $e', 'FishProvider', e);
    } finally {
      _setLoading(false);
    }
  }

  /// Clear all filters and search
  void clearFilters() {
    _currentSearchQuery = '';
    _currentHabitatFilter = null;
    _currentPreparationFilter = null;
    _filteredFish = List.from(_allFish);
    _searchResults = List.from(_allFish);
    notifyListeners();
  }

  /// Get a fish by ID
  Fish? getFishById(String id) {
    try {
      return _allFish.firstWhere((fish) => fish.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get popular fish (first 10 for now)
  List<Fish> getPopularFish() {
    return _allFish.take(10).toList();
  }

  /// Get sushi fish
  List<Fish> getSushiFish() {
    return _allFish.where((fish) => 
      fish.waysToEat.any((way) => 
        way.toLowerCase().contains('sushi') || 
        way.toLowerCase().contains('sashimi') ||
        way.toLowerCase().contains('nigiri')
      )
    ).toList();
  }

  /// Get random fish for discovery
  List<Fish> getRandomFish({int count = 5}) {
    final shuffled = List<Fish>.from(_allFish);
    shuffled.shuffle();
    return shuffled.take(count).toList();
  }

  /// Get all unique habitats
  List<String> getAllHabitats() {
    final Set<String> habitats = {};
    for (final fish in _allFish) {
      habitats.addAll(fish.habitats);
    }
    final sorted = habitats.toList();
    sorted.sort();
    return sorted;
  }

  /// Get all unique preparation methods
  List<String> getAllPreparations() {
    final Set<String> preparations = {};
    for (final fish in _allFish) {
      preparations.addAll(fish.waysToEat);
    }
    final sorted = preparations.toList();
    sorted.sort();
    return sorted;
  }

  /// Refresh all data
  Future<void> refresh() async {
    await loadAllFish();
  }

  /// Initialize the provider
  Future<void> initialize() async {
    await loadAllFish();
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
}