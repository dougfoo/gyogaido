import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:newproj/fish_cam.dart';
import 'dart:io';

class MockImagePicker extends Mock implements ImagePicker {}

void main() {
  late MockImagePicker mockImagePicker;
  late FishScanner fishScanner;

  setUp(() {
    mockImagePicker = MockImagePicker();
    fishScanner = FishScanner();
  });

  testWidgets('FishScanner displays no image selected initially', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: fishScanner));

    expect(find.text('No image selected.'), findsOneWidget);
  });

  testWidgets('FishScanner displays image after selection', (WidgetTester tester) async {
    final mockFile = File('test/fish-sample.jpg');
    try {
      FileStat fileStat = mockFile.statSync();
      if (fileStat.type == FileSystemEntityType.notFound) {
        print('File not found.');
        fail("File not found - check path");
      } else {
        print('File exists.');
      }
    } catch (e) {
      print('Error: $e');
    }

    when(mockImagePicker.pickImage(source: ImageSource.camera))
        .thenAnswer((_) async => XFile(mockFile.path));

    await tester.pumpWidget(MaterialApp(home: fishScanner));

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('FishScanner displays result after image identification', (WidgetTester tester) async {
    final mockFile = File('test/fish-sample.jpg');
    when(mockImagePicker.pickImage(source: ImageSource.camera))
        .thenAnswer((_) async => XFile(mockFile.path));

    await tester.pumpWidget(MaterialApp(home: fishScanner));

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Assuming _result is updated with some mock result
    expect(find.textContaining('Description'), findsOneWidget);
  });
}