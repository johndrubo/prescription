import 'package:get_it/get_it.dart';
import 'package:prescription_scanner/services/camera_service.dart';
import 'package:prescription_scanner/services/ml_service.dart';
import 'package:prescription_scanner/services/medex_service.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // Services
  getIt.registerLazySingleton<CameraService>(() => CameraService());
  getIt.registerLazySingleton<MlService>(() => MlService());
  getIt.registerLazySingleton<MedexService>(() => MedexService());
}

