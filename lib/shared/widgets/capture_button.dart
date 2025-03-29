import 'package:flutter/material.dart';
import 'package:prescription_scanner/core/app_theme.dart';

class CaptureButton extends StatelessWidget {
  final VoidCallback onPressed;
  
  const CaptureButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppTheme.gray.withAlpha(204),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            Icons.camera_alt,
            color: AppTheme.primary,
            size: 32,
          ),
        ),
      ),
    );
  }
}

