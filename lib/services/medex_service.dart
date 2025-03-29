import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:html/parser.dart' as parser;
import 'package:prescription_scanner/shared/models/medication_model.dart';

class MedexService {
  final String baseUrl = 'https://medex.com.bd';
  
  // Get the search URL for a medication
  String getMedicationSearchUrl(String medicationName) {
    return '$baseUrl/search?q=${Uri.encodeComponent(medicationName)}';
  }
  
  // Fetch medication details from Medex
  Future<Map<String, dynamic>> fetchMedicationDetails(String medicationName) async {
    try {
      final response = await http.get(
        Uri.parse(getMedicationSearchUrl(medicationName))
      );
      
      if (response.statusCode == 200) {
        // Parse the HTML response
        final document = parser.parse(response.body);
        
        // Extract medication information
        final medicationElements = document.querySelectorAll('.medicine-list-item');
        
        if (medicationElements.isNotEmpty) {
          final firstMedication = medicationElements.first;
          
          // Extract name
          final nameElement = firstMedication.querySelector('.medicine-name');
          final name = nameElement?.text.trim() ?? medicationName;
          
          // Extract company
          final companyElement = firstMedication.querySelector('.company-name');
          final company = companyElement?.text.trim() ?? 'Unknown';
          
          // Extract price
          final priceElement = firstMedication.querySelector('.price');
          final price = priceElement?.text.trim() ?? 'Price not available';
          
          // Extract link to details page
          final linkElement = firstMedication.querySelector('a');
          final detailsUrl = linkElement?.attributes['href'] ?? '';
          
          return {
            'name': name,
            'company': company,
            'price': price,
            'detailsUrl': detailsUrl.startsWith('http') ? detailsUrl : '$baseUrl$detailsUrl',
            'success': true,
          };
        }
        
        return {
          'success': false,
          'message': 'No medication found',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load medication details',
        };
      }
    } catch (e) {
      debugPrint('Error fetching medication details: $e');
      return {
        'success': false,
        'message': 'Network error while fetching medication details',
      };
    }
  }
  
  // Parse HTML content to extract medication information
  Future<List<Medication>> parseMedicationResults(String htmlContent) async {
    try {
      final document = parser.parse(htmlContent);
      final medicationElements = document.querySelectorAll('.medicine-list-item');
      
      final List<Medication> medications = [];
      
      for (final element in medicationElements) {
        // Extract name
        final nameElement = element.querySelector('.medicine-name');
        final name = nameElement?.text.trim() ?? 'Unknown';
        
        // Extract dosage (if available)
        final dosageElement = element.querySelector('.dosage');
        final dosage = dosageElement?.text.trim() ?? '500mg';
        
        // Create medication object
        medications.add(Medication(
          name: name,
          dosage: dosage,
          frequency: '3 times daily', // Default value
          duration: '7 days', // Default value
          confidence: 0.75, // Default confidence
        ));
        
        // Limit to 5 medications
        if (medications.length >= 5) break;
      }
      
      return medications;
    } catch (e) {
      debugPrint('Error parsing medication results: $e');
      return [];
    }
  }
}

