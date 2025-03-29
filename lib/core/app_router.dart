import 'package:flutter/material.dart';
import 'package:prescription_scanner/features/welcome/welcome_screen.dart';
import 'package:prescription_scanner/features/camera/camera_screen.dart';

class AppRouter {
  // Routes
  static const String welcomeRoute = '/';
  static const String cameraRoute = '/camera';
  static const String resultsRoute = '/results';
  static const String webviewRoute = '/webview';

  // Route map
  static Map<String, WidgetBuilder> get routes => {
        welcomeRoute: (context) => const WelcomeScreen(),
        cameraRoute: (context) => const CameraScreen(),
        // The ResultsScreen requires an imagePath parameter, so it can't be included in static routes
        // The WebviewScreen requires a medication parameter, so it can't be included in static routes
        // Both should be navigated to using Navigator.push with the required parameters
      };
}

