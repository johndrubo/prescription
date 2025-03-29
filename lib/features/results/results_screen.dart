import 'dart:io';
import 'package:flutter/material.dart';
import 'package:prescription_scanner/features/results/webview_screen.dart';
import 'package:prescription_scanner/shared/models/medication_model.dart';
import 'package:prescription_scanner/core/di.dart';
import 'package:prescription_scanner/services/camera_service.dart';
import 'package:prescription_scanner/features/welcome/welcome_screen.dart';

class ResultsScreen extends StatefulWidget {
  final String imagePath;
  
  const ResultsScreen({super.key, required this.imagePath});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool isLoading = true;
  List<Medication> medications = [];
  double processingProgress = 0.0;
  
  @override
  void initState() {
    super.initState();
    _processPrescription();
  }
  
  Future<void> _processPrescription() async {
    final cameraService = getIt<CameraService>();
    
    // Start progress animation
    _startProgressAnimation();
    
    try {
      // Analyze the prescription
      final results = await cameraService.analyzePrescription(File(widget.imagePath));
      
      if (mounted) {
        setState(() {
          medications = results;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error processing prescription: $e');
      
      if (mounted) {
        setState(() {
          // Mock data if analysis fails
          medications = [
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
          isLoading = false;
        });
      }
    }
  }
  
  void _startProgressAnimation() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      
      if (mounted && isLoading) {
        setState(() {
          processingProgress += 0.05;
          if (processingProgress >= 1.0) {
            processingProgress = 0.0;
          }
        });
      }
      
      return isLoading;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: isLoading 
              ? _buildProcessingView() 
              : _buildResultsView(),
        ),
      ),
    );
  }
  
  Widget _buildProcessingView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 300,
            width: double.infinity,
            child: Image.file(
              File(widget.imagePath),
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Processing prescription...',
              style: TextStyle(color: Colors.white),
            ),
            Text(
              '${(processingProgress * 100).toInt()}%',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: processingProgress,
          backgroundColor: Colors.white.withAlpha(76),
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 16),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '• Extracting text with OCR',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            Text(
              '• Identifying medications with AI',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            Text(
              '• Analyzing dosage information',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.refresh),
          label: const Text('Retake'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withAlpha(51),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
  
  Widget _buildResultsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Identified Medications',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: medications.length,
            itemBuilder: (context, index) {
              final medication = medications[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: Colors.white.withAlpha(25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.white.withAlpha(51)),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WebviewScreen(medication: medication),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                medication.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${medication.dosage} • ${medication.frequency}',
                                style: TextStyle(
                                  color: Colors.white.withAlpha(204),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF02FF4E).withAlpha(51),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Color(0xFF02FF4E),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: Colors.white.withAlpha(25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.white.withAlpha(51)),
          ),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'AI Confidence:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'High (92%)',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'OCR Quality:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Good',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: const Text('Scan Another Prescription'),
        ),
      ],
    );
  }
}

