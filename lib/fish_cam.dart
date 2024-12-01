import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:googleapis/vision/v1.dart' as vision;
import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FishScanner extends StatefulWidget {
  @override
  _FishScannerState createState() => _FishScannerState();
}

class _FishScannerState extends State<FishScanner> {
  File? _image;
  String _result = '';
  final picker = ImagePicker();

  Future<void> _getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
  
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        print ('Uploaded image');
        _identifyImage(_image!);
        print ('Returned from _identifyImage');
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _identifyImage(File image) async {
    print ("enter _identifyImage");

    final scopes = [vision.VisionApi.cloudPlatformScope];
    final credentialsJson = dotenv.env['GOOGLE_CLOUD_CREDENTIALS']!;
    final credentials = ServiceAccountCredentials.fromJson(credentialsJson);
    final client = await clientViaServiceAccount(credentials, scopes);

    final visionApi = vision.VisionApi(client);
    print ("vision Api ${visionApi.toString()}");
    final imageBytes = await image.readAsBytes();  // gets stuck here why ?
    print ("size of image bytes: ${imageBytes}");

    final base64Image = base64Encode(imageBytes);

    final request = vision.BatchAnnotateImagesRequest.fromJson({
      'requests': [
        {
          'image': {'content': base64Image},
          'features': [
            {'type': 'LABEL_DETECTION', 'maxResults': 10}
          ]
        }
      ]
    });

    final response = await visionApi.images.annotate(request);

    setState(() {
      _result = response.responses!.first.labelAnnotations!
          .map((label) => label.description)
          .join(', ');
    });

    // Print debug message with image information
    print('Uploaded image information:');
    response.responses!.first.labelAnnotations!.forEach((label) {
      print('Description: ${label.description}, Score: ${label.score}');
    });

    client.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fish Scanner'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image == null
                ? const Text('No image selected.')
                : kIsWeb
                  ? Image.network(_image!.path)
                  : Image.file(_image!),
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
