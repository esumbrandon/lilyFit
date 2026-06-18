import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';

class GeminiService {
  final GenerativeModel _model;

  GeminiService()
      : _model = GenerativeModel(
          model: 'gemini-2.0-flash',
          apiKey: const String.fromEnvironment('GEMINI_API_KEY'),
        );

  Future<Map<String, dynamic>> analyzeImage(XFile image) async {
    final prompt = [
      Content.system(
        'You are an expert nutritionist. Your role is to analyze images of food and return a detailed nutritional analysis in a structured JSON format. The user will provide an image, and you must identify the food items, estimate their weight, and calculate the total calories and macronutrients. Your response must strictly be a JSON object with the following schema: '
        '{"is_food": true/false, "confidence_score": 0.0-1.0, "total_estimated_calories": 0, "macronutrients": {"carbohydrates_g": 0, "protein_g": 0, "fat_g": 0}, "identified_items": [{"name": "Item name", "estimated_weight_g": 0, "calories": 0}], "health_insight": "A brief, encouraging tip about the meal."}'
        'If the image does not contain food, set "is_food" to false and the other fields to their default values. Do not include any text or formatting outside of the JSON object.',
      ),
      Content.multi([
        TextPart(
          'Analyze the food in this image and provide its nutritional information in the specified JSON format.',
        ),
        DataPart('image/jpeg', File(image.path).readAsBytesSync()),
      ]),
    ];

    try {
      final response = await _model.generateContent(prompt);
      final jsonString = response.text;
      if (jsonString != null) {
        // Find the JSON part of the response
        final jsonStart = jsonString.indexOf('{');
        final jsonEnd = jsonString.lastIndexOf('}');
        if (jsonStart != -1 && jsonEnd != -1) {
          final justJson = jsonString.substring(jsonStart, jsonEnd + 1);
          return json.decode(justJson) as Map<String, dynamic>;
        }
      }
      throw const FormatException('Invalid JSON response from Gemini');
    } catch (e) {
      throw Exception('Error analyzing image with Gemini: $e');
    }
  }
}