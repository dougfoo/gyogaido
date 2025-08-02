// import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
// import 'package:googleapis/vision/v1.dart' as vision;
// import 'package:googleapis_auth/auth_io.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

class FishScanner extends StatefulWidget {
  @override
  _FishScannerState createState() => _FishScannerState();
}

class _FishScannerState extends State<FishScanner> {
  XFile? _image;
  String _result = '';
  final picker = ImagePicker();

  Future<void> _getImage() async {
    XFile? pickedFile;
    if (kIsWeb) {
      pickedFile = await picker.pickImage(source: ImageSource.gallery);
    } else {
      pickedFile = await picker.pickImage(source: ImageSource.camera);
    }

    setState(() {
      if (pickedFile != null) {
        _image = pickedFile;
        print('Uploaded image');
        if (!kIsWeb) {
          _identifyImage(pickedFile);
        }
        print('Returned from _identifyImage');
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _identifyImage(XFile image) async {
    print("enter _identifyImage");
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
      imageWidget = const Text('No image selected.');
    } else if (kIsWeb) {
      imageWidget = Image.network(_image!.path);
    } else {
      imageWidget = Image.file(
        // ignore: prefer_const_constructors
        File(_image!.path),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fish Scanner'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            imageWidget,
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getImage,
              child: const Text('Take Photo'),
            ),
            const SizedBox(height: 20),
            Text(
              _result,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
