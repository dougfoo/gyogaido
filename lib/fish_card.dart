// FILE: lib/fish_card.dart

import 'package:flutter/material.dart';

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

class FullScreenFishCard extends StatelessWidget {
  final int index;
  final ImageSize imageSize;

  const FullScreenFishCard({
    required this.index,
    required this.imageSize,
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

    double imageWidth = MediaQuery.of(context).size.height * 0.75; // Default width to 75% of height

    return Scaffold(
      appBar: AppBar(
        title: Text('Fish $index'),
      ),
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Row(
            children: <Widget>[
              if (imageSize != ImageSize.noshow) // Conditionally show the image
                Container(
                  width: imageWidth,
                  height: MediaQuery.of(context).size.height * imageHeightFactor,
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
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Description of the fish. This is a placeholder text to simulate a longer description that spans multiple lines.',
                        style: TextStyle(fontSize: 18),
                        maxLines: 10,
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
    );
  }
}