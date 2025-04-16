import 'dart:convert';
import 'package:http/http.dart' as http;

class FoodApiService {
  // Get your free API key from https://fdc.nal.usda.gov/api-key-signup.html
  final String apiKey =
      '3ZHgNRkc7Zcj1CDaDbyrIzKKOEYQzLYK7EAyQxQO'; // You can use DEMO_KEY for testing, or get your free key
  final String baseUrl = 'https://api.nal.usda.gov/fdc/v1/foods/search';

  Future<Map<String, dynamic>> searchFood(String query) async {
    try {
      print('Searching for food: $query');
      final url = Uri.parse(
        '$baseUrl?api_key=$apiKey&query=$query&pageSize=25&dataType=Survey (FNDDS)',
      );
      print('API URL: $url');

      final response = await http.get(url);
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['foods'] != null && data['foods'].isNotEmpty) {
          print('Found ${data['foods'].length} food items');
          return data;
        } else {
          print('No foods found in response');
          throw Exception('No foods found');
        }
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load food data: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('Error searching for food: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Error searching for food: $e');
    }
  }

  // Helper method to extract nutrition values from API response
  Map<String, dynamic> extractNutrition(Map<String, dynamic> foodData) {
    try {
      if (foodData['foods'] != null && foodData['foods'].isNotEmpty) {
        final food = foodData['foods'][0];
        print('Processing food: ${food['description']}');
        final nutrients = food['foodNutrients'];
        print('Found ${nutrients.length} nutrients');

        double findNutrientValue(int nutrientId) {
          try {
            final nutrient = nutrients.firstWhere(
              (n) => n['nutrientId'] == nutrientId,
              orElse: () => {'value': 0},
            );
            print('Nutrient $nutrientId value: ${nutrient['value']}');
            return (nutrient['value'] ?? 0).toDouble();
          } catch (e) {
            print('Error finding nutrient $nutrientId: $e');
            return 0.0;
          }
        }

        final result = {
          'calories': findNutrientValue(1008).round(), // Energy
          'protein': findNutrientValue(1003).round(), // Protein
          'carbohydrates': findNutrientValue(1005).round(), // Carbs
          'fat': findNutrientValue(1004).round(), // Total fat
          'fiber': findNutrientValue(1079).round(), // Fiber
        };
        print('Extracted nutrition values: $result');
        return result;
      }
      print('No valid food data found');
      return {
        'calories': 0,
        'protein': 0,
        'carbohydrates': 0,
        'fat': 0,
        'fiber': 0,
      };
    } catch (e) {
      print('Error extracting nutrition: $e');
      return {
        'calories': 0,
        'protein': 0,
        'carbohydrates': 0,
        'fat': 0,
        'fiber': 0,
      };
    }
  }
}
