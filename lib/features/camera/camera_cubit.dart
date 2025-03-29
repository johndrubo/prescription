import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prescription_scanner/services/camera_service.dart';
import 'package:prescription_scanner/shared/models/medication_model.dart';

enum CameraState { initial, capturing, processing, success, error }

class CameraCubit extends Cubit<CameraState> {
  final CameraService _cameraService;
  
  CameraCubit(this._cameraService) : super(CameraState.initial);

  Future<List<Medication>> analyzeImage(File imageFile) async {
    emit(CameraState.processing);
    
    try {
      final medications = await _cameraService.analyzePrescription(imageFile);
      
      emit(CameraState.success);
      return medications;
    } catch (e) {
      emit(CameraState.error);
      return [];
    }
  }
}

