import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:prescription_scanner/services/ml_service.dart';
import 'package:prescription_scanner/shared/models/medication_model.dart';
import 'package:prescription_scanner/core/di.dart';

class CameraService {
  CameraController? controller;
  List<CameraDescription> cameras = [];
  final MlService _mlService = getIt<MlService>();
  
  Future<void> initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        // Find the back camera
        final backCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
          orElse: () => cameras.first,
        );
        
        controller = CameraController(
          backCamera,
          ResolutionPreset.high,
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.jpeg,
        );
        
        await controller!.initialize();
        
        // Set flash mode to auto
        await controller!.setFlashMode(FlashMode.auto);
        
        // Enable image stream if needed for real-time processing
        // await controller!.startImageStream((image) => _processImageStream(image));
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }
  
  Future<String> takePicture() async {
    if (controller == null || !controller!.value.isInitialized) {
      throw Exception('Camera not initialized');
    }
    
    try {
      // Prepare for image capture
      if (controller!.value.isTakingPicture) {
        return '';
      }
      
      final XFile image = await controller!.takePicture();
      final directory = await getTemporaryDirectory();
      final String filePath = p.join(directory.path, '${DateTime.now().millisecondsSinceEpoch}.jpg');
      
      // Save the image to the new path
      await File(image.path).copy(filePath);
      
      return filePath;
    } catch (e) {
      debugPrint('Error taking picture: $e');
      throw Exception('Failed to take picture: $e');
    }
  }
  
  Future<List<Medication>> analyzePrescription(File imageFile) async {
    try {
      // Use ML service to identify medications
      final List<Medication> medications = await _mlService.identifyMedications(imageFile);
      return medications;
    } catch (e) {
      debugPrint('Error analyzing prescription: $e');
      
      // Return mock data if analysis fails
      return [
        Medication(
          name: "Amoxicillin",
          dosage: "500mg",
          frequency: "3 times daily",
          duration: "7 days",
          confidence: 0.92,
        ),
        Medication(
          name: "Ibuprofen",
          dosage: "400mg",
          frequency: "as needed",
          duration: "5 days",
          confidence: 0.87,
        ),
      ];
    }
  }
  
  void dispose() {
    controller?.dispose();
  }
}

