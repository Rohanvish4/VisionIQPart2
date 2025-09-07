import 'dart:developer' as developer;
import 'dart:io';
import 'dart:convert';
import 'dart:math';

import 'package:google_generative_ai/google_generative_ai.dart';
import '../model/gemini_model.dart';

class GeminiService {
  static final String apiKey = "AIzaSyDQWM-YvzqUkGcIVDGHE6DSirDYa2fUOnQ";

  static const int _maxRetries = 3;
  static const Duration _initialDelay = Duration(seconds: 1);
  static String cleanJson(String raw) {
    return raw
        .replaceAll(RegExp(r'^```json'), '')
        .replaceAll(RegExp(r'^```'), '')
        .replaceAll(RegExp(r'```$'), '')
        .trim();
  }

  static String getRandomApiKey() {
    final keys = [apiKey];
    final randomIndex = Random().nextInt(keys.length);
    developer.log('Random API Key: ${keys[randomIndex]}');
    return keys[randomIndex];
  }

  static Future<GeminiModel?> extractDataFromImage(File imageFile) async {
    if (getRandomApiKey().isEmpty) {
      developer.log('API Key not found. Set GeminiService.apiKey');
      return null;
    }

    int retries = 0;
    Duration currentDelay = _initialDelay;

    while (retries < _maxRetries) {
      try {
        final model = GenerativeModel(
          model: 'gemini-2.5-flash',
          apiKey: getRandomApiKey(),
        );
        final imageBytes = await imageFile.readAsBytes();

        final prompt = TextPart("""
Analyze this video frame or image and extract all possible information. 
Provide the output in a clean JSON format without markdown tags.

The JSON object should include:
- environment_type (e.g., home, shop, office, etc.)
- detected_items (list of objects, each with item_name, quantity as int, confidence_score as float)
- infrastructure (list of objects for furniture/infrastructure such as shelves, counters, tables, chairs, cupboards, etc., each with quantity and confidence_score)
- inventory (list of objects for shop/home items such as bottles, boxes, electronics, appliances, clothing, decorative items, etc., each with quantity and confidence_score)
- total_items_count (integer representing the sum of all detected items)
- location_context (string describing possible context like household, commercial shop, office)
- use_case (e.g., Home Environment Analysis, Shop Environment Analysis)
- structured_report_format (JSON or CSV)
- confidence_summary (average confidence across detections as float)
""");

        final imagePart = DataPart('image/jpeg', imageBytes);

        final response = await model.generateContent([
          Content.multi([prompt, imagePart]),
        ]);

        if (response.text != null) {
          developer.log('Gemini API raw response: ${response.text}');
          final jsonMap = jsonDecode(cleanJson(response.text!));
          final model = GeminiModel.fromJson(jsonMap);
          developer.log('Gemini API response: $jsonMap');
          return model;
        } else {
          developer.log("Gemini API returned no text.");
          return null;
        }
      } catch (e) {
        developer.log('Error calling Gemini API: $e');
        retries++;
        await Future.delayed(currentDelay);
        currentDelay *= 2;
        if (retries >= _maxRetries) return null;
      }
    }

    return null;
  }
}
