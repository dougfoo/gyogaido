import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'fish_card.dart'; // Import the new file

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gyo Gai Do',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 178, 66, 25)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Gyo Gai Do'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _goToFishScanner() {
    _pageController.jumpToPage(1);
  }

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (_pageController.page == _pageController.initialPage - 1) {
        _pageController.jumpToPage(3);
      } else if (_pageController.page == 4) {
        _pageController.jumpToPage(0);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(), // Ensure physics allows swiping both ways
        children: <Widget>[
          // First screen: current screen
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'You have entered the greatest sushi app in the world:',
                  style: TextStyle(fontSize: 30), 
                ),
                Image.asset('images/fish_sushi.jpg'),
              ],
            ),
          ),
          // Second screen: FishScanner
          FishScanner(),
          // Third screen: FishFavorites
          FishFavorites(),
          // Fourth screen: FishLibrary
          FishLibrary(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToFishScanner,
        tooltip: 'Photo Scan a fish',
        child: const FaIcon(FontAwesomeIcons.fish),
      ),
    );
  }
}

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

