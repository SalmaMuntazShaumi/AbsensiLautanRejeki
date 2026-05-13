import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class CameraService {

  static CameraController? _controller;
  static List<CameraDescription>? _cameras;

  /// Initialize camera
  static Future<void> initializeCamera() async {

    try {

      final status =
      await Permission.camera.request();

      if (status.isDenied ||
          status.isPermanentlyDenied) {

        throw Exception(
          'Camera permission denied',
        );
      }

      _cameras = await availableCameras();

      if (_cameras == null ||
          _cameras!.isEmpty) {

        throw Exception(
          'No camera available',
        );
      }

      _controller = CameraController(
        _cameras!.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();

    } catch (e) {

      throw Exception(
        'Failed to initialize camera: $e',
      );
    }
  }

  /// Get controller
  static CameraController? getController() {

    return _controller;

  }

  /// Take picture and return File
  static Future<File> takePicture() async {

    try {

      if (_controller == null ||
          !_controller!.value.isInitialized) {

        throw Exception(
          'Camera not initialized',
        );
      }

      final image =
      await _controller!.takePicture();

      return File(image.path);

    } catch (e) {

      throw Exception(
        'Failed to take picture: $e',
      );
    }
  }

  /// Dispose
  static Future<void> disposeCamera() async {

    try {

      if (_controller != null) {

        await _controller!.dispose();

        _controller = null;
      }

    } catch (e) {

      print(
        'Error disposing camera: $e',
      );
    }
  }
}