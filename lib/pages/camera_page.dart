import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:lautanrejeki/services/camera_service.dart';
import 'package:lautanrejeki/src/colors.dart';

class CameraPage extends StatefulWidget {
  final String clockType; // 'in' or 'out'
  final String token;
  final String? earlyOutReason;

  const CameraPage({
    super.key,
    required this.clockType,
    required this.token,
    this.earlyOutReason,
  });

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;

  bool _isInitialized = false;
  bool _isCapturing = false;

  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera([int cameraIndex = 1]) async {
    try {
      _cameras = await availableCameras();

      // Default ke front camera kalau ada
      if (_cameras.length > cameraIndex) {
        _selectedCameraIndex = cameraIndex;
      } else {
        _selectedCameraIndex = 0;
      }

      _controller = CameraController(
        _cameras[_selectedCameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera error: $e')),
        );

        Navigator.pop(context);
      }
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;

    setState(() {
      _isInitialized = false;
    });

    _selectedCameraIndex =
        (_selectedCameraIndex + 1) % _cameras.length;

    await _controller?.dispose();

    _controller = CameraController(
      _cameras[_selectedCameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _controller!.initialize();

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  Future<void> _takePicture() async {

    if (_isCapturing || _controller == null) return;

    try {

      setState(() {
        _isCapturing = true;
      });

      final XFile picture =
      await _controller!.takePicture();

      final imageFile = File(picture.path);

      if (mounted) {

        Navigator.pop(
          context,
          {
            'photo': imageFile,
            'clockType': widget.clockType,
            'token': widget.token,
            'reason': widget.earlyOutReason,
          },
        );
      }

    } catch (e) {

      if (mounted) {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Camera error: $e'),
          ),
        );

        setState(() {
          _isCapturing = false;
        });
      }
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
        title: Text(
          'Take ${widget.clockType == 'in' ? 'Clock-In' : 'Clock-Out'} Photo',
        ),
        backgroundColor: AppColors.primaryColor,
        actions: [
          IconButton(
            onPressed: _switchCamera,
            icon: const Icon(Icons.flip_camera_ios),
          ),
        ],
      ),
      body: _isInitialized && _controller != null
          ? Stack(
        children: [
          CameraPreview(_controller!),

          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _isCapturing ? null : _takePicture,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isCapturing
                        ? Colors.grey
                        : AppColors.primaryColor,
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                    ),
                  ),
                  child: _isCapturing
                      ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      valueColor:
                      AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
        ],
      )
          : const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}