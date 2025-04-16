import 'package:flutter/material.dart';
import '../services/food_api_service.dart';
import 'dart:async';

class FoodSearchWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onFoodSelected;

  const FoodSearchWidget({Key? key, required this.onFoodSelected})
    : super(key: key);

  @override
  _FoodSearchWidgetState createState() => _FoodSearchWidgetState();
}

class _FoodSearchWidgetState extends State<FoodSearchWidget> {
  final FoodApiService _foodApiService = FoodApiService();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  Timer? _debounce;
  Map<String, dynamic>? _searchResult;
  bool _isLoading = false;
  String? _error;
  String _selectedPortion = 'serving';
  double _quantity = 1.0;

  final Map<String, double> _portionSizes = {
    'serving': 1.0,
    'cup': 240.0,
    'tablespoon': 15.0,
    'teaspoon': 5.0,
    'gram': 1.0,
    'ounce': 28.35,
    'piece': 1.0,
  };

  @override
  void initState() {
    super.initState();
    _quantityController.text = '1.0';
    _searchController.addListener(_onSearchChanged);
  }

  _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.isNotEmpty) {
        _searchFood(_searchController.text);
      } else {
        setState(() {
          _searchResult = null;
          _error = null;
        });
      }
    });
  }

  Future<void> _searchFood(String query) async {
    if (query.isEmpty) return;

    print('Starting search for: $query');

    setState(() {
      _isLoading = true;
      _error = null;
      _searchResult = null;
    });

    try {
      final result = await _foodApiService.searchFood(query);
      print('Search result: $result');
      if (mounted) {
        setState(() {
          _searchResult = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Search error: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _updateQuantity(String value) {
    try {
      setState(() {
        _quantity = double.parse(value);
      });
    } catch (e) {
      print('Invalid quantity: $value');
    }
  }

  Map<String, dynamic> _adjustNutritionForPortion(
    Map<String, dynamic> nutritionData,
  ) {
    double multiplier =
        _quantity * (_portionSizes[_selectedPortion] ?? 1.0) / 100.0;
    return {
      'calories': (nutritionData['calories'] * multiplier).round(),
      'protein': (nutritionData['protein'] * multiplier).round(),
      'carbohydrates': (nutritionData['carbohydrates'] * multiplier).round(),
      'fat': (nutritionData['fat'] * multiplier).round(),
      'fiber': (nutritionData['fiber'] * multiplier).round(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Food',
                hintText: 'Enter food name (e.g., apple, rice)',
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchResult = null;
                              _error = null;
                            });
                          },
                        )
                        : null,
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(child: _buildSearchResults()),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text(_error!, style: const TextStyle(color: Colors.red)),
      );
    }

    if (_searchResult != null && _searchResult!['foods'] != null) {
      return ListView.builder(
        itemCount: _searchResult!['foods'].length,
        itemBuilder: (context, index) {
          final food = _searchResult!['foods'][index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ExpansionTile(
              title: Text(food['description'] ?? 'Unknown Food'),
              subtitle: Text('Tap to select portion size'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: _quantityController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Quantity',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: _updateQuantity,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            flex: 3,
                            child: DropdownButtonFormField<String>(
                              value: _selectedPortion,
                              decoration: InputDecoration(
                                labelText: 'Portion',
                                border: OutlineInputBorder(),
                              ),
                              items:
                                  _portionSizes.keys.map((String portion) {
                                    return DropdownMenuItem<String>(
                                      value: portion,
                                      child: Text(portion),
                                    );
                                  }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedPortion = newValue;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          final nutritionData = _foodApiService
                              .extractNutrition({
                                'foods': [food],
                              });
                          final adjustedNutrition = _adjustNutritionForPortion(
                            nutritionData,
                          );
                          widget.onFoodSelected(adjustedNutrition);
                        },
                        child: Text('Add to Daily Intake'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: Size(double.infinity, 36),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    return const Center(child: Text('Type a food name to search'));
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _debounce?.cancel();
    _searchController.dispose();
    _quantityController.dispose();
    super.dispose();
  }
}
