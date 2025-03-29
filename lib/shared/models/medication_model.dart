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
}

