import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ImageUtils {
  // Enhance image for OCR processing
  static Future<File> enhanceForOCR(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      var decodedImage = img.decodeImage(bytes);
      
      if (decodedImage == null) {
        throw Exception('Could not decode image');
      }
      
      // Apply image processing for better OCR results
      
      // 1. Increase contrast
      decodedImage = img.adjustColor(
        decodedImage,
        contrast: 1.5,
        brightness: 0.0,
        saturation: 0.0,
      );
      
      // 2. Convert to grayscale for better text recognition
      final grayscale = img.grayscale(decodedImage);
      
      // 3. Apply adaptive thresholding for better text/background separation
      final thresholded = _adaptiveThreshold(grayscale, 15, 5);
      
      // Save the processed image
      final tempDir = await getTemporaryDirectory();
      final processedImagePath = p.join(tempDir.path, 'processed_${p.basename(imageFile.path)}');
      
      final processedFile = File(processedImagePath);
      await processedFile.writeAsBytes(img.encodeJpg(thresholded));
      
      return processedFile;
    } catch (e) {
      debugPrint('Error enhancing image: $e');
      return imageFile; // Return original if processing fails
    }
  }
  
  // Adaptive thresholding algorithm for better text extraction
  static img.Image _adaptiveThreshold(img.Image src, int kernelSize, int constant) {
    final result = img.Image(width: src.width, height: src.height);
    
    for (int y = 0; y < src.height; y++) {
      for (int x = 0; x < src.width; x++) {
        // Calculate local mean
        int sum = 0;
        int count = 0;
        
        for (int ky = -kernelSize ~/ 2; ky <= kernelSize ~/ 2; ky++) {
          for (int kx = -kernelSize ~/ 2; kx <= kernelSize ~/ 2; kx++) {
            final int px = x + kx;
            final int py = y + ky;
            
            if (px >= 0 && px < src.width && py >= 0 && py < src.height) {
              sum += img.getLuminance(src.getPixel(px, py)).toInt();
              count++;
            }
          }
        }
        
        final int mean = count > 0 ? (sum ~/ count) : 0;
        final int srcPixel = img.getLuminance(src.getPixel(x, y)).toInt();
        
        // Apply threshold
        final int resultPixel = srcPixel > (mean - constant) ? 255 : 0;
        result.setPixelRgb(x, y, resultPixel, resultPixel, resultPixel);
      }
    }
    
    return result;
  }
  
  // Resize image to fit model input
  static Future<File> resizeForModel(File imageFile, int width, int height) async {
    try {
      final bytes = await imageFile.readAsBytes();
      var decodedImage = img.decodeImage(bytes);
      
      if (decodedImage == null) {
        throw Exception('Could not decode image');
      }
      
      // Resize the image
      final resized = img.copyResize(
        decodedImage,
        width: width,
        height: height,
      );
      
      // Save the resized image
      final tempDir = await getTemporaryDirectory();
      final resizedImagePath = p.join(tempDir.path, 'resized_${p.basename(imageFile.path)}');
      
      final resizedFile = File(resizedImagePath);
      await resizedFile.writeAsBytes(img.encodeJpg(resized));
      
      return resizedFile;
    } catch (e) {
      debugPrint('Error resizing image: $e');
      return imageFile; // Return original if processing fails
    }
  }
}

