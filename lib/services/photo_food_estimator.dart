import 'dart:math';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import '../data/food_database.dart';
import '../models/food_item.dart';

class PhotoFoodEstimate {
  final FoodItem? food;
  final double confidence;
  final List<String> labels;

  const PhotoFoodEstimate({
    required this.food,
    required this.confidence,
    required this.labels,
  });

  double? get calories => food?.calories;
}

class PhotoFoodEstimator {
  final ImageLabeler _labeler = ImageLabeler(
    options: ImageLabelerOptions(confidenceThreshold: 0.45),
  );

  static const Map<String, List<String>> _labelToFoodHints = {
    'burger': ['cheeseburger'],
    'sandwich': ['turkey sandwich', 'avocado toast'],
    'pizza': ['pepperoni pizza'],
    'fries': ['french fries'],
    'rice': ['jollof rice', 'fried rice', 'brown rice', 'risotto', 'waakye'],
    'sushi': ['salmon sushi roll'],
    'ramen': ['ramen'],
    'noodle': ['ramen', 'pad thai', 'pho', 'pasta carbonara'],
    'pasta': ['pasta carbonara'],
    'salad': ['caesar salad', 'greek salad'],
    'steak': ['ribeye steak', 'schnitzel', 'suya', 'nyama choma'],
    'chicken': [
      'grilled chicken breast',
      'kung pao chicken',
      'tandoori chicken',
    ],
    'egg': ['scrambled eggs'],
    'pancake': ['pancakes', 'crepe'],
    'bread': ['naan bread', 'avocado toast', 'bruschetta'],
    'fish': ['salmon fillet', 'fish and chips', 'thieboudienne'],
    'soup': [
      'egusi soup',
      'ogbono soup',
      'pepper soup',
      'miso soup',
      'borscht',
    ],
    'banana': ['banana', 'fried plantain (dodo)'],
    'apple': ['apple'],
    'croissant': ['croissant'],
    'pretzel': ['pretzels'],
  };

  Future<PhotoFoodEstimate> estimateFromImagePath(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final labels = await _labeler.processImage(inputImage);

    if (labels.isEmpty) {
      return const PhotoFoodEstimate(food: null, confidence: 0, labels: []);
    }

    final Map<FoodItem, double> scores = {};
    final normalizedFoods = <FoodItem, String>{
      for (final food in FoodDatabase.foods) food: _normalize(food.name),
    };

    for (final label in labels) {
      final labelText = _normalize(label.label);
      if (labelText.isEmpty) {
        continue;
      }

      final confidence = label.confidence;
      final labelTokens = labelText
          .split(' ')
          .where((t) => t.length >= 3)
          .toSet();

      for (final entry in normalizedFoods.entries) {
        final food = entry.key;
        final foodName = entry.value;
        double score = 0;

        if (foodName.contains(labelText) || labelText.contains(foodName)) {
          score += confidence * 3.0;
        }

        final matchedTokens = labelTokens.where(foodName.contains).length;
        if (matchedTokens > 0) {
          score += matchedTokens * confidence * 1.2;
        }

        for (final hint in _labelToFoodHints.entries) {
          if (!labelText.contains(hint.key)) {
            continue;
          }
          for (final hintedFood in hint.value) {
            if (foodName.contains(_normalize(hintedFood))) {
              score += confidence * 2.2;
            }
          }
        }

        if (score > 0) {
          scores[food] = (scores[food] ?? 0) + score;
        }
      }
    }

    if (scores.isEmpty) {
      return PhotoFoodEstimate(
        food: null,
        confidence: 0,
        labels: labels.map((e) => e.label).toList(),
      );
    }

    final sorted = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final best = sorted.first;
    final topScore = best.value;
    final secondScore = sorted.length > 1 ? sorted[1].value : 0;
    final calibratedConfidence =
        (topScore / max(topScore + secondScore, 0.0001)).clamp(0.0, 1.0);

    return PhotoFoodEstimate(
      food: best.key,
      confidence: calibratedConfidence,
      labels: labels.map((e) => e.label).toList(),
    );
  }

  String _normalize(String input) {
    final lower = input.toLowerCase();
    final cleaned = lower.replaceAll(RegExp(r'[^a-z0-9 ]'), ' ');
    return cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  void dispose() {
    _labeler.close();
  }
}
