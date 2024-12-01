import 'package:flutter/material.dart';
import 'fish_card.dart'; // Import the new file

// todo:
//    build camera integration
//        


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
