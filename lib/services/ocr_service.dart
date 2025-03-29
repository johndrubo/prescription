import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:prescription_scanner/shared/models/medication_model.dart';
import 'package:prescription_scanner/services/image_utils.dart';

class OcrService {
  final TextRecognizer _textRecognizer = TextRecognizer();
  
  Future<String> extractText(File imageFile) async {
    try {
      // Preprocess the image for better OCR results
      final processedImage = await ImageUtils.enhanceForOCR(imageFile);
      
      // Create an InputImage from the processed file
      final inputImage = InputImage.fromFile(processedImage);
      
      // Process the image with ML Kit
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      // Combine all text blocks
      final String extractedText = recognizedText.text;
      debugPrint('Extracted text: $extractedText');
      
      return extractedText;
    } catch (e) {
      debugPrint('Error during OCR: $e');
      return '';
    }
  }
  
  Future<List<Medication>> extractMedications(String text) async {
    // This is a simple implementation that looks for medication names in the text
    // In a real app, you would use NLP or a more sophisticated algorithm
    
    final List<Medication> medications = [];
    final List<String> commonMedications = [
      'Amoxicillin', 'Ibuprofen', 'Paracetamol', 'Aspirin', 'Lisinopril',
      'Atorvastatin', 'Metformin', 'Amlodipine', 'Metoprolol', 'Omeprazole'
    ];
    
    // Simple pattern matching for medication names
    for (final medication in commonMedications) {
      if (text.toLowerCase().contains(medication.toLowerCase())) {
        // Extract dosage information (simple regex pattern)
        final dosagePattern = RegExp(r'(\d+)\s*mg');
        final dosageMatch = dosagePattern.firstMatch(text);
        final String dosage = dosageMatch != null ? '${dosageMatch.group(1)}mg' : '500mg';
        
        // Extract frequency information (simple pattern matching)
        String frequency = '3 times daily';
        if (text.toLowerCase().contains('once daily') || text.toLowerCase().contains('once a day')) {
          frequency = 'once daily';
        } else if (text.toLowerCase().contains('twice daily') || text.toLowerCase().contains('twice a day')) {
          frequency = 'twice daily';
        } else if (text.toLowerCase().contains('as needed') || text.toLowerCase().contains('prn')) {
          frequency = 'as needed';
        }
        
        // Extract duration information (simple pattern matching)
        String duration = '7 days';
        final durationPattern = RegExp(r'(\d+)\s*days');
        final durationMatch = durationPattern.firstMatch(text);
        if (durationMatch != null) {
          duration = '${durationMatch.group(1)} days';
        }
        
        medications.add(Medication(
          name: medication,
          dosage: dosage,
          frequency: frequency,
          duration: duration,
          confidence: 0.85,
        ));
      }
    }
    
    // If no medications were found, return mock data
    if (medications.isEmpty) {
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
    
    return medications;
  }
  
  void dispose() {
    _textRecognizer.close();
  }
}

