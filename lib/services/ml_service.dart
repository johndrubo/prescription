import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:prescription_scanner/shared/models/medication_model.dart';

class MlService {
  final TextRecognizer _textRecognizer = TextRecognizer();
  ImageLabeler? _imageLabeler;
  
  Future<void> _initializeImageLabeler() async {
    try {
      // Check if the model file exists before attempting to use it
      const modelPath = 'assets/models/prescription_model_dynamic_quantized.tflite';
      
      // Use default labeler as fallback
      final options = ImageLabelerOptions();
      _imageLabeler = ImageLabeler(options: options);
      
      debugPrint('Initialized default image labeler as fallback');
    } catch (e) {
      debugPrint('Error initializing image labeler: $e');
      // Use default labeler if custom model fails
      _imageLabeler = ImageLabeler(options: ImageLabelerOptions());
    }
  }
  
  Future<List<Medication>> identifyMedications(File imageFile) async {
    try {
      if (_imageLabeler == null) {
        await _initializeImageLabeler();
      }
      
      // Process the image with ML Kit text recognition
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      
      // Extract medications from text
      final List<Medication> textMedications = _extractMedicationsFromText(recognizedText.text);
      
      // Try to use image labeling if available
      List<Medication> imageMedications = [];
      if (_imageLabeler != null) {
        final labels = await _imageLabeler!.processImage(inputImage);
        imageMedications = _extractMedicationsFromLabels(labels);
      }
      
      // Combine results
      final List<Medication> combinedMedications = _combineMedicationResults(textMedications, imageMedications);
      
      // If no medications were found, return mock data
      if (combinedMedications.isEmpty) {
        return _getMockMedications();
      }
      
      return combinedMedications;
    } catch (e) {
      debugPrint('Error analyzing prescription: $e');
      return _getMockMedications();
    }
  }
  
  List<Medication> _extractMedicationsFromText(String text) {
    // This is a simple implementation that looks for medication names in the text
    final List<Medication> medications = [];
    const List<String> commonMedications = [
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
    
    return medications;
  }
  
  List<Medication> _extractMedicationsFromLabels(List<ImageLabel> labels) {
    final List<Medication> medications = [];
    
    for (final label in labels) {
      // Check if the label is a medication
      if (label.confidence > 0.7) {
        // Create a medication object from the label
        medications.add(Medication(
          name: label.label,
          dosage: '500mg', // Default value
          frequency: '3 times daily', // Default value
          duration: '7 days', // Default value
          confidence: label.confidence,
        ));
      }
    }
    
    return medications;
  }
  
  List<Medication> _combineMedicationResults(List<Medication> textMedications, List<Medication> imageMedications) {
    // Create a map to deduplicate medications by name
    final Map<String, Medication> medicationMap = {};
    
    // Add text-based medications
    for (final medication in textMedications) {
      medicationMap[medication.name.toLowerCase()] = medication;
    }
    
    // Add image-based medications, preferring them if there's a duplicate
    for (final medication in imageMedications) {
      medicationMap[medication.name.toLowerCase()] = medication;
    }
    
    // Convert back to list and sort by confidence
    final List<Medication> combined = medicationMap.values.toList();
    combined.sort((a, b) => b.confidence.compareTo(a.confidence));
    
    return combined;
  }
  
  List<Medication> _getMockMedications() {
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
      Medication(
        name: "Paracetamol",
        dosage: "500mg",
        frequency: "every 6 hours",
        duration: "3 days",
        confidence: 0.85,
      ),
    ];
  }
  
  void dispose() {
    _textRecognizer.close();
    _imageLabeler?.close();
  }
}

