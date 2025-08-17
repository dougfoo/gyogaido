// import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'utils/logger.dart';
// import 'package:googleapis/vision/v1.dart' as vision;
// import 'package:googleapis_auth/auth_io.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

class FishScanner extends StatefulWidget {
  const FishScanner({super.key});

  @override
  State<FishScanner> createState() => _FishScannerState();
}

class _FishScannerState extends State<FishScanner> {
  XFile? _image;
  String _result = '';
  bool _isLoading = false;
  final picker = ImagePicker();

  Future<void> _getImage([ImageSource? source]) async {
    setState(() {
      _isLoading = true;
      _result = '';
    });

    XFile? pickedFile;
    final ImageSource imageSource = source ?? ImageSource.camera;
    
    try {
      pickedFile = await picker.pickImage(
        source: imageSource,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80,
      );
      
      if (pickedFile != null) {
        Logger.info('Image captured from ${imageSource.name}', 'FishScanner');
      }
    } catch (e) {
      Logger.error('Error accessing ${imageSource.name}: $e', 'FishScanner', e);
      setState(() {
        _result = 'Error: Could not access ${imageSource.name}. Please check permissions.';
      });
    }

    setState(() {
      _isLoading = false;
      if (pickedFile != null) {
        _image = pickedFile;
        _result = 'Image captured successfully! ${kIsWeb ? '(Web mode - identification disabled)' : ''}';
        
        // Only run identification on mobile/desktop
        if (!kIsWeb) {
          _identifyImage(pickedFile);
        }
      } else if (_result.isEmpty) {
        _result = 'No image selected.';
      }
    });
  }

  Future<void> _identifyImage(XFile image) async {
    Logger.debug('enter _identifyImage', 'FishScanner');
    // Only run this on mobile/desktop, not web
    if (kIsWeb) return;

    // Uncomment and implement your Google Vision API logic here for mobile/desktop
    // final imageBytes = await image.readAsBytes();
    // final base64Image = base64Encode(imageBytes);
    // ...
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    if (_image == null) {
      imageWidget = Container(
        width: 300,
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text('No image selected', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    } else if (kIsWeb) {
      imageWidget = Container(
        width: 300,
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            _image!.path,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Text('Error loading image', style: TextStyle(color: Colors.red)),
              );
            },
          ),
        ),
      );
    } else {
      imageWidget = Container(
        width: 300,
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(_image!.path),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fish Scanner'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              imageWidget,
              const SizedBox(height: 30),
              
              // Camera and Gallery buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : () => _getImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : () => _getImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Loading indicator
              if (_isLoading)
                const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text('Accessing camera...', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              
              // Result text
              if (!_isLoading && _result.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: _result.contains('Error') ? Colors.red.shade50 : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _result.contains('Error') ? Colors.red.shade200 : Colors.green.shade200,
                    ),
                  ),
                  child: Text(
                    _result,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: _result.contains('Error') ? Colors.red.shade700 : Colors.green.shade700,
                    ),
                  ),
                ),
              
              const SizedBox(height: 20),
              
              // Web-specific instructions
              if (kIsWeb)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.info, color: Colors.blue),
                      SizedBox(height: 8),
                      Text(
                        'Web Mode: Camera access requires browser permissions.\nClick "Camera" to activate your laptop camera.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
