class Medication {
  final String name;
  final String dosage;
  final String frequency;
  final String duration;
  final double confidence;
  
  Medication({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.duration,
    this.confidence = 0.0,
  });
  
  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      name: json['name'] as String,
      dosage: json['dosage'] as String,
      frequency: json['frequency'] as String,
      duration: json['duration'] as String,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
      'confidence': confidence,
    };
  }
}

class PrescriptionAnalysisResult {
  final List<Medication> medications;
  final String ocrQuality;
  final int processingTimeMs;
  final String? error;
  
  PrescriptionAnalysisResult({
    required this.medications,
    required this.ocrQuality,
    required this.processingTimeMs,
    this.error,
  });
  
  factory PrescriptionAnalysisResult.fromJson(Map<String, dynamic> json) {
    return PrescriptionAnalysisResult(
      medications: (json['medications'] as List)
          .map((item) => Medication.fromJson(item as Map<String, dynamic>))
          .toList(),
      ocrQuality: json['ocrQuality'] as String,
      processingTimeMs: json['processingTimeMs'] as int,
      error: json['error'] as String?,
    );
  }
}

