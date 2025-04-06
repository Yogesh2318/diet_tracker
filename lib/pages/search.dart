import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class Info {
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fats;

  Info({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
  });
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchController = TextEditingController();
  Info? searchedInfo;
  bool hasSearched = false;

  final List<Info> foodData = [
    Info(name: "Roti", calories: 100, protein: 3, carbs: 18, fats: 1),
    Info(name: "Rice", calories: 200, protein: 4, carbs: 44, fats: 0.5),
    Info(name: "Paneer", calories: 265, protein: 18, carbs: 6, fats: 20),
    Info(name: "Dal", calories: 150, protein: 9, carbs: 25, fats: 1),
  ];

  void performSearch(String query) {
    if (query.isEmpty) return;

    setState(() {
      hasSearched = true;
      searchedInfo = foodData.firstWhere(
            (food) => food.name.toLowerCase() == query.toLowerCase(),
        orElse: () => Info(name: "Not Found", calories: 0, protein: 0, carbs: 0, fats: 0),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "Food Nutrition Search",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Search Bar with Shadow
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: "Search for a food item",
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Icon(Icons.search, color: Colors.blue[300]),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear, color: Colors.grey[400]),
                      onPressed: () {
                        searchController.clear();
                        setState(() {
                          hasSearched = false;
                          searchedInfo = null;
                        });
                      },
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  onSubmitted: performSearch,
                ),
              ),

              const SizedBox(height: 20),

              // Suggestions row when no search is performed
              if (!hasSearched)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      child: Text(
                        "Popular Foods",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: foodData.map((food) => GestureDetector(
                        onTap: () {
                          searchController.text = food.name;
                          performSearch(food.name);
                        },
                        child: Chip(
                          backgroundColor: Colors.blue.withOpacity(0.1),
                          label: Text(
                            food.name,
                            style: TextStyle(color: Colors.blue[700]),
                          ),
                          avatar: CircleAvatar(
                            backgroundColor: Colors.blue[100],
                            child: Text(
                              food.name[0],
                              style: TextStyle(color: Colors.blue[700], fontSize: 12),
                            ),
                          ),
                        ),
                      )).toList(),
                    ),
                  ],
                ),

              // Search Results
              if (searchedInfo != null && searchedInfo!.name != "Not Found")
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top: 20),
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Food Name Card
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 8,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  searchedInfo!.name,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "${searchedInfo!.calories.toStringAsFixed(0)} calories per serving",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 24),

                          // Macronutrient Summary
                          Text(
                            "Macronutrients",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 16),

                          // Nutrient Cards in a Row
                          Row(
                            children: [
                              _buildNutrientCard("Protein", "${searchedInfo!.protein.toStringAsFixed(1)}g", Colors.blue),
                              SizedBox(width: 8),
                              _buildNutrientCard("Carbs", "${searchedInfo!.carbs.toStringAsFixed(1)}g", Colors.orange),
                              SizedBox(width: 8),
                              _buildNutrientCard("Fats", "${searchedInfo!.fats.toStringAsFixed(1)}g", Colors.green),
                            ],
                          ),

                          SizedBox(height: 24),

                          // Pie Chart
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 8,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Macronutrient Breakdown",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 16),
                                SizedBox(
                                  height: 200,
                                  child: PieChart(
                                    PieChartData(
                                      sectionsSpace: 2,
                                      centerSpaceRadius: 40,
                                      sections: [
                                        PieChartSectionData(
                                          value: searchedInfo!.carbs,
                                          color: Colors.orange.shade300,
                                          title: 'Carbs',
                                          radius: 60,
                                          titleStyle: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                        PieChartSectionData(
                                          value: searchedInfo!.protein,
                                          color: Colors.blue.shade300,
                                          title: 'Protein',
                                          radius: 60,
                                          titleStyle: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                        PieChartSectionData(
                                          value: searchedInfo!.fats,
                                          color: Colors.green.shade300,
                                          title: 'Fats',
                                          radius: 60,
                                          titleStyle: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16),
                                // Legend
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildLegendItem("Carbs", Colors.orange.shade300),
                                    SizedBox(width: 24),
                                    _buildLegendItem("Protein", Colors.blue.shade300),
                                    SizedBox(width: 24),
                                    _buildLegendItem("Fats", Colors.green.shade300),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 24),

                          // Calorie Progress
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 8,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Calories",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 16),
                                _buildProgressBar(
                                  value: searchedInfo!.calories,
                                  maxValue: 2000,
                                  color: Colors.red.shade300,
                                  label: "${searchedInfo!.calories.toStringAsFixed(0)} / 2000 kcal",
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (searchedInfo != null && hasSearched)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Food not found",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Try another search term",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutrientCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color:Colors.blue[100],
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color:Colors.blue[100],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar({
    required double value,
    required double maxValue,
    required Color color,
    required String label,
  }) {
    final percentage = (value / maxValue).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            Text(
              "${(percentage * 100).toStringAsFixed(0)}%",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.8 * percentage,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.7), color],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}