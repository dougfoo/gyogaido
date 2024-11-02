// FILE: lib/fish_card.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


enum ImageSize { noshow, small, medium, large }

class FishCard extends StatelessWidget {
  final int index;
  final double height;
  final ImageSize imageSize;

  const FishCard({
    required this.index,
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
      default:
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
              index: index,
              imageSize: imageSize,
            ),
          ),
        );
      },
      child: Tooltip(
        message: 'Click for details',
        child: Card(
          child: Container(
            height: height, // Use the height parameter
            child: Row(
              children: <Widget>[
                if (imageSize != ImageSize.noshow) // Conditionally show the image
                  Container(
                    width: imageWidth,
                    height: height * imageHeightFactor,
                    child: Image.asset(
                      'assets/images/fish_thumbnail.png', // Replace with your image asset
                      fit: BoxFit.cover,
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Fish $index',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Description of the fish. This is a placeholder text to simulate a longer description that spans multiple lines.',
                          style: TextStyle(fontSize: 14),
                          maxLines: 4,
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
  final int index;
  final ImageSize imageSize;

  const FullScreenFishCard({
    required this.index,
    required this.imageSize,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fish $index'),
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
                  Image.asset(
                    'assets/images/fish_thumbnail.png', // Replace with your image asset
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Fish $index',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Description of the fish. This is a placeholder text to simulate a longer description that spans multiple lines.',
                        style: TextStyle(fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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
              const Text('Common aliases: alias1, alias2, alias3, alias4, alias5'),
              const Text('Scientific name: scientificname'),
              const Text('Japanese name: romaji (日本語)'),
              const Text('Lifespan: 5yr 3mo'),
              const Text('Size: 5in 12cm'),
              const Text('Weight: 5lb 2kg'),
              const Text('Habitats: country1, country2, country3, country4, country5, country6, country7, country8'),
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
                      'assets/images/fish_sushi.jpg', // Replace with your image asset
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
                      'assets/images/wild_fish.png', // Replace with your image asset
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Image.asset(
                      'assets/images/wild_fish.png', // Replace with your image asset
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
                    // Open Google search for the fish by "unique name"
                    final query = 'Fish $index';
                    final url = 'https://www.google.com/search?q=$query';
                    if (await canLaunch(url)) {
                      await launch(url);
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