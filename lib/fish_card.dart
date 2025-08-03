// FILE: lib/fish_card.dart - Real fish data implementation

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'models/fish.dart';
import 'providers/favorites_provider.dart';

// todo list
//  - add button to toggle "add to favorites" ✓
//  - 

enum ImageSize { noshow, small, medium, large }

class FishCard extends StatelessWidget {
  final Fish fish;
  final double height;
  final ImageSize imageSize;

  const FishCard({
    super.key,
    required this.fish,
    this.height = 120,
    this.imageSize = ImageSize.large,
  });

  @override
  Widget build(BuildContext context) {
    double imageHeightFactor;
    switch (imageSize) {
      case ImageSize.noshow:
        imageHeightFactor = 0;
        break;
      case ImageSize.small:
        imageHeightFactor = 1 / 3;
        break;
      case ImageSize.medium:
        imageHeightFactor = 2 / 3;
        break;
      case ImageSize.large:
        imageHeightFactor = 1;
        break;
    }

    double imageWidth = height * 0.75; // Default width to 75% of height

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullScreenFishCard(
              fish: fish,
              imageSize: imageSize,
            ),
          ),
        );
      },
      child: Tooltip(
        message: 'Click for details',
        child: Card(
          child: SizedBox(
            height: height,
            child: Row(
              children: <Widget>[
                if (imageSize != ImageSize.noshow)
                  SizedBox(
                    width: imageWidth,
                    height: height * imageHeightFactor,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                      child: Image.asset(
                        fish.primarySushiImage.isNotEmpty 
                          ? fish.primarySushiImage 
                          : 'assets/images/fish_sushi.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.image_not_supported),
                          );
                        },
                      ),
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                fish.uniqueName,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Consumer<FavoritesProvider>(
                              builder: (context, favoritesProvider, child) {
                                final isFavorite = favoritesProvider.isFavorite(fish.id);
                                return IconButton(
                                  icon: Icon(
                                    isFavorite ? Icons.favorite : Icons.favorite_border,
                                    color: isFavorite ? Colors.red : Colors.grey,
                                  ),
                                  onPressed: () {
                                    favoritesProvider.toggleFavorite(fish.id);
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                        Text(
                          fish.japaneseNameRomaji,
                          style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          fish.description,
                          style: const TextStyle(fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// change card UI design as follows
// top section:  
//     top left has a small photo of the live fish
//     to right is name of fish in bold medium font (the name is the "unique name" in this app)
//     description below in smaller font (2 lines)
// middle section:  
//    middle has metadata information with title:  Fun Facts in bold medium font
//       common aliases:  (list of 20 char max words, max 5 words)
//       scientific name:  (20 char max)
//       japanese name (20 char in romaji and 20 char in japanese characters) 
//       lifespan: ( in years and months format like:  5yr 3mo)
//       size: (in inches and cm format like:  5in 12cm)
//       weight: (in lbs and kg format like:  5lb 2kg)
//       habitats:  (list of 2 char max words, max 8 words that represent countries)
//    bottom section has photos of the fish
//       first row are photos of sushi
//       second row are photos of the fish in the wild
//       third row is a map of the world highlighting where the fish is found
//    very bottom has a link "google for more" that opens google search for the fish by "unique name" 

class FullScreenFishCard extends StatelessWidget {
  final Fish fish;
  final ImageSize imageSize;

  const FullScreenFishCard({
    super.key,
    required this.fish,
    required this.imageSize,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fish.uniqueName),
        actions: [
          Consumer<FavoritesProvider>(
            builder: (context, favoritesProvider, child) {
              final isFavorite = favoritesProvider.isFavorite(fish.id);
              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : null,
                ),
                onPressed: () {
                  favoritesProvider.toggleFavorite(fish.id);
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Top section
              Row(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      fish.primaryWildImage.isNotEmpty 
                        ? fish.primaryWildImage 
                        : 'assets/images/fish_sushi.jpg',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          fish.uniqueName,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          fish.japaneseNameRomaji + (fish.japaneseNameKanji.isNotEmpty ? ' (${fish.japaneseNameKanji})' : ''),
                          style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          fish.description,
                          style: const TextStyle(fontSize: 14),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Middle section
              const Text(
                'Fun Facts',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text('Common aliases: ${fish.aliasesString}'),
              Text('Scientific name: ${fish.scientificName}'),
              Text('Japanese name: ${fish.japaneseNameRomaji} (${fish.japaneseNameKanji})'),
              Text('Ways to eat: ${fish.waysToEatString}'),
              Text('Lifespan: ${fish.lifespan}'),
              Text('Size: ${fish.size}'),
              Text('Weight: ${fish.weight}'),
              Text('Habitats: ${fish.habitatString}'),
              const SizedBox(height: 20),
              // Bottom section
              const Text(
                'Photos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              // First row: photos of sushi
              Row(
                children: <Widget>[
                  Expanded(
                    child: Image.asset(
                      'assets/images/fish_sushi.jpg', // Replace with your image asset
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Image.asset(
                      'assets/images/fish_sushi2.jpg', // Replace with your image asset
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Second row: photos of the fish in the wild
              Row(
                children: <Widget>[
                  Expanded(
                    child: Image.asset(
                      'assets/images/wild_fish.jpg', // Replace with your image asset
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Image.asset(
                      'assets/images/wild_fish2.jpg', // Replace with your image asset
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Third row: map of the world highlighting where the fish is found
              Image.asset(
                'assets/images/world_map.png', // Replace with your image asset
                height: 100,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),
              // Very bottom: link to Google search
              Center(
                child: TextButton(
                  onPressed: () async {
                    // Open Google search for the fish by unique name
                    final query = Uri.encodeComponent('${fish.uniqueName} ${fish.scientificName} fish');
                    final url = Uri.parse('https://www.google.com/search?q=$query');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                  child: const Text('Google for more'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}