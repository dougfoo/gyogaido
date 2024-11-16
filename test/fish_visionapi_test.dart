import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:newproj/fish_cam.dart';
import 'dart:io';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart' show InputImage;
import 'package:googleapis/vision/v1.dart' as vision;
import 'package:googleapis_auth/auth_io.dart';


void main() {
 
  setUp(() {
    final mockFile = File('test/fish-sample.jpg');
  });

  // write 2 tests, 1 is to check that the mockFile exists and is readable
  // 2 is to use the google vision API to identify the fish in the image
  test('Check that the mockFile exists and is readable', () {
    final mockFile = File('test/fish-sample.jpg');
    expect(mockFile.existsSync(), true);
    expect(mockFile.readAsBytesSync().isNotEmpty, true);
  });

  test('Use the Google Vision API to identify the fish in the image', () async {
    final image = File('test/fish-sample.jpg');

    final credentials = ServiceAccountCredentials.fromJson(r'''
      {
        "type": "service_account",
        "project_id": "gyogaido-v1",
        "private_key_id": "b68f338d64c645b883a7c4ebd08e0b6e82a7e5c4",
        "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQDYU+OJazLSis2P\nyKniwu+tNhi/UCifn6+rdTC25mm0G1Mi5aKp1qeJLPLMgsPT24LsIEmFfHjtuUmz\n4sRWXso2LNIdHIA1j7AKPqekKN4dGI6NRpUUd5E0A9nhmUNtexBvSOHuXQWe1m3u\nCgm69nBGxTy1Ob3SwyqeRyK14cWDYceK3kk8ubL5KyJLu+a2HtmGiP3zkWcgxTN/\nG3wmMfwUnsyER9yLkg8Uo7xAgVapo8jlT3OxHjnuCjETTesmkx50tSRLSBCOT+4j\ngFXNpPDlN65PshzvbXfm75G3y8Fub+OCBRJh1Zn5OMj+kIl+ouXNVGm6cBCcy4v/\nvmyK92UpAgMBAAECggEAapFg7QhnH/sK6wMiVbhMVBrrNAvsBz6mTqPLnL6DYht3\n6CAR8vLw043WClN83vgrVeFN9rlr5Ug6+6gBqr7FhMytsXOh4UDoqxNUiHUtfk3j\no8sak9uXJ3WiNxXGdr+CSCAyVLd0llvyCareQkE27FYr4ucQESzd6N0IR2tyXpa7\n0ueFkPDprgO3S2MghpIghoFtau1nP5uMmHlUcZr0IR11RzjHSPnCHcmDfjdgMmqY\nlS6GqF8g0YBY6PKKT5Ihw2n9cmXcPaf3p50opG7P+DYZY3Q6acqLUePb0BE+W4Yy\nzafaEvpSemnynbPwKk5WeJBCMunj94eYNLMf78bDhQKBgQDuFK4P5SJEe1400Ubf\n9pS+R5ZcWLbsbMJrj+5LMh6uMXmXkV0FYm8Jd/HRYz73j6OZbl1nVsqgF+8vuPqL\nRFYHnYFNbeYGCDP/VZe1G5fX2VJrF7rQ5ikugvJCGjK7r8zWgWv30a6PbMAUuNy8\no1YEJxFUTwUWsSHSrlNRr7Qv/wKBgQDonBJ8LuLf7f+Bt577PLUdV5e4t1pg+OUd\nllYbg0z1+00vAygA8UozQ99+SBGshIqf239Bgx/6qjkWCcqVMSwN5FfrSawMgpIq\nU1iEZA/m0lPlfS05zGi6rp6QsU9KrTYvjUKSlWH8Dk/L2V3k9cO8lpyRj4L+yzYl\nueaz+Tzq1wKBgHGRT86pQIVmS/Pp+GMRXra9s03ty6RP5RYmHEematgxJY1VfAf7\ngngDzUhSjVDOJf4klU2cKx/fCuu601jnihor2egzikxKUXN1Qt7TgMUoF5aaRTUs\n9WwIbsN1d8nr/Ew+hGA8l4Y3HBFGdZVOXNOyRyPuZcEDUd0L5xbKN6vFAoGALO4w\nt+IKmryLFRBV2iugxFkuClUIVSDeiLeITGoxTHZNM16FtKDm9z4OBoN/PnafnD82\ntn3QiIem3TXo9qZ33vsTbHRfkk8KUrikqXX2iFxqLjLesIJmXGDsagCF02PfypGb\noVrPgXN2QGbtNxOtyljBR3CUGglAnUrqYCstdCMCgYBLHLKHtOLfBYJ1cE2ohqnq\nTETyB51rFJojG3H8W1hALP7q+4qUU5uufqa4EmbXD9pT0cgGoEiCtP+X2kY4dBgG\nKg7FAjiKWfbJif5OhitJxkhxpdvi5wfSGCf+vf2YpeyZYXYugxK5ZV7T5TBgcUQu\nqup5JrBQn/7T6v0oLCkCoQ==\n-----END PRIVATE KEY-----\n",
        "client_email": "svcaccount1@gyogaido-v1.iam.gserviceaccount.com",
        "client_id": "110878302933935007925",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/svcaccount1%40gyogaido-v1.iam.gserviceaccount.com",
        "universe_domain": "googleapis.com"
      }
    ''');

    final scopes = [vision.VisionApi.cloudPlatformScope];
    final client = await clientViaServiceAccount(credentials, scopes);

    final visionApi = vision.VisionApi(client);
    print ("visiion Api ${visionApi.toString()}");
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

    // Print debug message with image information
    print('Uploaded image information:');
    response.responses!.first.labelAnnotations!.forEach((label) {
      print('Description: ${label.description}, Score: ${label.score}');
    });


  });
}
