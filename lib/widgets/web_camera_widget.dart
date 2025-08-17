import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../utils/logger.dart';

/// Web-specific camera widget that provides live camera access
/// This widget is designed specifically for web platforms where
/// image_picker doesn't support camera access
class WebCameraWidget extends StatefulWidget {
  final Function(XFile) onImageCaptured;
  final VoidCallback? onCancel;

  const WebCameraWidget({
    super.key,
    required this.onImageCaptured,
    this.onCancel,
  });

  @override
  State<WebCameraWidget> createState() => _WebCameraWidgetState();
}

class _WebCameraWidgetState extends State<WebCameraWidget> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitializing = true;
  String? _errorMessage;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      Logger.info('Initializing camera for web...', 'WebCameraWidget');
      
      // Get available cameras
      _cameras = await availableCameras();
      
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() {
          _errorMessage = 'No cameras found on this device.';
          _isInitializing = false;
        });
        return;
      }

      // Use the first available camera (usually front camera on laptops)
      final camera = _cameras!.first;
      Logger.info('Found ${_cameras!.length} camera(s), using: ${camera.name}', 'WebCameraWidget');

      // Create camera controller
      _controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false, // We don't need audio for photos
      );

      // Initialize the controller
      await _controller!.initialize();
      
      Logger.info('Camera initialized successfully', 'WebCameraWidget');
      
      setState(() {
        _isInitializing = false;
      });
      
    } catch (e) {
      Logger.error('Failed to initialize camera: $e', 'WebCameraWidget', e);
      setState(() {
        _errorMessage = 'Failed to access camera: ${e.toString()}';
        _isInitializing = false;
      });
    }
  }

  Future<void> _capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      Logger.info('Capturing photo...', 'WebCameraWidget');
      final XFile photo = await _controller!.takePicture();
      Logger.info('Photo captured successfully: ${photo.path}', 'WebCameraWidget');
      
      // Return the captured image to parent
      widget.onImageCaptured(photo);
      
    } catch (e) {
      Logger.error('Failed to capture photo: $e', 'WebCameraWidget', e);
      setState(() {
        _errorMessage = 'Failed to capture photo: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isCapturing = false;
      });
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length <= 1) {
      return; // No other cameras available
    }

    try {
      setState(() {
        _isInitializing = true;
      });

      // Dispose current controller
      await _controller?.dispose();

      // Find next camera
      final currentCameraIndex = _cameras!.indexWhere(
        (camera) => camera == _controller!.description,
      );
      final nextCameraIndex = (currentCameraIndex + 1) % _cameras!.length;
      final nextCamera = _cameras![nextCameraIndex];

      Logger.info('Switching to camera: ${nextCamera.name}', 'WebCameraWidget');

      // Initialize new camera
      _controller = CameraController(
        nextCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();

      setState(() {
        _isInitializing = false;
      });

    } catch (e) {
      Logger.error('Failed to switch camera: $e', 'WebCameraWidget', e);
      setState(() {
        _errorMessage = 'Failed to switch camera: ${e.toString()}';
        _isInitializing = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Switch camera button (if multiple cameras available)
          if (_cameras != null && _cameras!.length > 1)
            IconButton(
              icon: const Icon(Icons.flip_camera_ios),
              onPressed: _isInitializing ? null : _switchCamera,
              tooltip: 'Switch Camera',
            ),
          // Cancel button
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: widget.onCancel,
            tooltip: 'Cancel',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _buildCaptureButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildBody() {
    if (_isInitializing) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Initializing camera...'),
            SizedBox(height: 8),
            Text(
              'Please allow camera permissions when prompted',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.camera_alt_outlined,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                'Camera Error',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _errorMessage = null;
                    _isInitializing = true;
                  });
                  _initializeCamera();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: Text('Camera not available'));
    }

    // Camera preview
    return Stack(
      children: [
        // Full screen camera preview
        Center(
          child: AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: CameraPreview(_controller!),
          ),
        ),
        
        // Overlay with instructions
        Positioned(
          top: 20,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              kIsWeb 
                ? 'Position your fish in the camera view and tap the capture button'
                : 'Position your fish and tap capture',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCaptureButton() {
    return FloatingActionButton.large(
      onPressed: (_isCapturing || _controller == null || !_controller!.value.isInitialized) 
          ? null 
          : _capturePhoto,
      backgroundColor: _isCapturing ? Colors.grey : Theme.of(context).primaryColor,
      child: _isCapturing
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            )
          : const Icon(
              Icons.camera_alt,
              size: 32,
              color: Colors.white,
            ),
    );
  }
}