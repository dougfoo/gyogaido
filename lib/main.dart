import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'fish_views.dart';
import 'fish_cam.dart';
import 'providers/fish_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/app_state_provider.dart';
import 'services/fish_service.dart';
import 'utils/logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database
  await FishService.initializeDatabase();
  
  // await dotenv.load(fileName: ".env");
  runApp(const GyoGaiDoApp());
}

// todo:
//   fix so scroll left also works
//   fix help to bring up info (change to info icon as well) 
//   implement camera 

class GyoGaiDoApp extends StatelessWidget {
  const GyoGaiDoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ChangeNotifierProvider(create: (_) => FishProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: MaterialApp(
        title: 'Gyo Gai Do',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 178, 66, 25)),
          useMaterial3: true,
        ),
        home: const AppInitializer(),
      ),
    );
  }
}

/// Widget to initialize providers and show loading state
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    // Delay initialization to next frame to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProviders();
    });
  }

  Future<void> _initializeProviders() async {
    try {
      final fishProvider = Provider.of<FishProvider>(context, listen: false);
      final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
      final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);

      // Initialize all providers
      await Future.wait([
        fishProvider.initialize(),
        favoritesProvider.initialize(),
        appStateProvider.initializeApp(),
      ]);
    } catch (e) {
      Logger.error('Error initializing providers: $e', 'main', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<FishProvider, FavoritesProvider, AppStateProvider>(
      builder: (context, fishProvider, favoritesProvider, appStateProvider, child) {
        // Show loading screen while initializing
        if (fishProvider.isLoading || favoritesProvider.isLoading || appStateProvider.isAppLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading fish database...'),
                ],
              ),
            ),
          );
        }

        // Show error if initialization failed
        if (fishProvider.error != null || appStateProvider.appError != null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load app data',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    fishProvider.error ?? appStateProvider.appError ?? 'Unknown error',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _initializeProviders,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // Show main app when loaded
        return const MyHomePage(title: 'Gyo Gai Do');
      },
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

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _onItemTapped(int index) {
    _pageController.jumpToPage(index);
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Help'),
          content: const Text(
            'Welcome to Gyu Gai Do!\n\n'
            '1. Scan a fish: Use the camera icon to scan a fish and identify it.\n'
            '2. Add to favorites: Save your favorite fish for easy access.\n'
            '3. Learn more in the fish library: Explore detailed information about various fish species.\n\n'
            'Use the bottom navigation bar to switch between the home screen, scanner, favorites, and library.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(), // Ensure physics allows swiping both ways
      
        children: <Widget>[
          // First screen: current screen
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'The Gaijin Guide to Gyo (Fish):',
                  style: TextStyle(fontSize: 30), 
                ),
                Image.asset('assets/images/fish_sushi.jpg'),
                const SizedBox(height: 5),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FaIcon(FontAwesomeIcons.camera),
                    SizedBox(width: 10),
                    Text(
                      'Scan a fish',
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FaIcon(FontAwesomeIcons.heart),
                    Text(
                      'Add to favorites',
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FaIcon(FontAwesomeIcons.book),
                    Text(
                      'Learn more in the fish library',
                      style: TextStyle(fontSize: 20),
                    ),
                  ]
                ),
              ]            ),
          ),
          // Second screen: FishScanner
          const FishScanner(),
          // Third screen: FishFavorites
          const FishFavorites(),
          // Fourth screen: FishLibrary
          const FishLibrary(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onItemTapped(1),
        tooltip: 'Scan',
        child: const FaIcon(FontAwesomeIcons.photoFilm),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue, // Set the background color to blue
        selectedItemColor: Colors.green, // Set the selected item color to white
        unselectedItemColor: Colors.blueGrey, // Set the unselected item color to white

        currentIndex: _currentPage,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.house),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.camera),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.heart),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.book),
            label: 'Library',
          ),
        ],
      ),
    );
  }
}
