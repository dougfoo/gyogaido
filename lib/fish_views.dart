import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'fish_card.dart';
import 'providers/fish_provider.dart';
import 'providers/favorites_provider.dart';
import 'models/fish.dart';

// todo:
//    build camera integration with Google Vision API
//        

class FishFavorites extends StatelessWidget {
  const FishFavorites({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fish Favorites'),
      ),
      body: Consumer<FavoritesProvider>(
        builder: (context, favoritesProvider, child) {
          if (favoritesProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (favoritesProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${favoritesProvider.error}'),
                  ElevatedButton(
                    onPressed: () => favoritesProvider.refresh(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final favoriteFish = favoritesProvider.favoriteFish;

          if (favoriteFish.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No favorite fish yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add fish to favorites by tapping the heart icon',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: favoriteFish.length,
            itemBuilder: (context, index) {
              return FishCard(
                fish: favoriteFish[index],
                height: 120,
                imageSize: ImageSize.large,
              );
            },
          );
        },
      ),
    );
  }
}

class FishLibrary extends StatelessWidget {
  const FishLibrary({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fish Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: FishSearchDelegate(),
              );
            },
          ),
        ],
      ),
      body: Consumer<FishProvider>(
        builder: (context, fishProvider, child) {
          if (fishProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (fishProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${fishProvider.error}'),
                  ElevatedButton(
                    onPressed: () => fishProvider.refresh(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final allFish = fishProvider.allFish;

          if (allFish.isEmpty) {
            return const Center(
              child: Text('No fish data available'),
            );
          }

          return ListView.builder(
            itemCount: allFish.length,
            itemBuilder: (context, index) {
              return FishCard(
                fish: allFish[index],
                height: 80,
                imageSize: ImageSize.medium,
              );
            },
          );
        },
      ),
    );
  }
}

/// Search delegate for fish search functionality
class FishSearchDelegate extends SearchDelegate<Fish?> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final fishProvider = Provider.of<FishProvider>(context, listen: false);

    if (query.isEmpty) {
      return const Center(
        child: Text('Enter a fish name to search'),
      );
    }

    return FutureBuilder<void>(
      future: fishProvider.searchFish(query),
      builder: (context, snapshot) {
        return Consumer<FishProvider>(
          builder: (context, fishProvider, child) {
            if (fishProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final searchResults = fishProvider.searchResults;

            if (searchResults.isEmpty) {
              return Center(
                child: Text('No fish found for "$query"'),
              );
            }

            return ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                return FishCard(
                  fish: searchResults[index],
                  height: 80,
                  imageSize: ImageSize.medium,
                );
              },
            );
          },
        );
      },
    );
  }
}
