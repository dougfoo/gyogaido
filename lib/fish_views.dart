import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'fish_card.dart'; // Import the new file


class FishScanner extends StatelessWidget {
  const FishScanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fish Scanner'),
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FaIcon(
                FontAwesomeIcons.camera,
                size: 100,
              ),
              SizedBox(height: 20),
              Text(
                'Take photo of fish to identify and add to your favorites',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FishFavorites extends StatelessWidget {
  const FishFavorites({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fish Favorites'),
      ),
      body: ListView(
        children: List.generate(5, (index) => FishCard(index: index)),
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
      ),
      body: ListView(
        children: List.generate(20, (index) => FishCard(index: index, height: 80, imageSize: ImageSize.medium)),
      ),
    );
  }
}
