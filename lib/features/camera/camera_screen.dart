import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:prescription_scanner/features/results/results_screen.dart';
import 'package:prescription_scanner/core/di.dart';
import 'package:prescription_scanner/services/camera_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dotted_border/dotted_border.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  late CameraService _cameraService;
  CameraController? _controller;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cameraService = getIt<CameraService>();
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    await _cameraService.initializeCamera();
    _controller = _cameraService.controller;
    
    if (mounted) {
      setState(() {
        _isCameraInitialized = _controller?.value.isInitialized ?? false;
      });
    }
  }

  Future<void> _takePicture() async {
    try {
      final imagePath = await _cameraService.takePicture();
      
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsScreen(imagePath: imagePath),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error taking picture: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error capturing image')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    color: Colors.grey,
                    child: Center(
                      child: _isCameraInitialized
                          ? Stack(
                              alignment: Alignment.center,
                              children: [
                                CameraPreview(_controller!),
                                DottedBorder(
                                  color: const Color(0xFF02FF4E),
                                  strokeWidth: 2,
                                  borderType: BorderType.RRect,
                                  radius: const Radius.circular(8),
                                  padding: const EdgeInsets.all(0),
                                  dashPattern: const [6, 3],
                                  child: Container(
                                    margin: const EdgeInsets.all(32),
                                    height: double.infinity,
                                    width: double.infinity,
                                  ),
                                ),
                                const Center(
                                  child: Text(
                                    'Line your prescription in the dashed area',
                                    style: TextStyle(
                                      color: Color(0xFF02FF4E),
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            )
                          : const CircularProgressIndicator(),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey.withAlpha(204),
                    radius: 24,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF6200EE)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 24),
                  GestureDetector(
                    onTap: _takePicture,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.grey.withAlpha(204),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/svg/camera.svg',
                          width: 32,
                          height: 32,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF6200EE),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

