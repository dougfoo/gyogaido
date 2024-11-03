import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis/vision/v1.dart' as vision;
import 'package:googleapis_auth/auth_io.dart';

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
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _identifyImage(File image) async {
    final credentials = ServiceAccountCredentials.fromJson(r'''
{
/// insert from cloud api - iam - cred json file
/// 
}
    ''');

    final scopes = [vision.VisionApi.cloudPlatformScope];
    final client = await clientViaServiceAccount(credentials, scopes);

    final visionApi = vision.VisionApi(client);
    final imageBytes = await image.readAsBytes();
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
