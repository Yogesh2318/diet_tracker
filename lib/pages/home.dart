import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:my_project/model/usermodel.dart';
import '../widgets/food_search.dart';

// Step 1: Create a Meal class
class Meal {
  final String name;
  final double calories;
  final double protein;
  final double nutrients;
  final DateTime timestamp;

  Meal({
    required this.name,
    required this.calories,
    required this.protein,
    required this.nutrients,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'calories': calories,
      'protein': protein,
      'nutrients': nutrients,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      name: map['name'] as String,
      calories: (map['calories'] as num).toDouble(),
      protein: (map['protein'] as num).toDouble(),
      nutrients: (map['nutrients'] as num).toDouble(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    );
  }
}

class Home extends StatefulWidget {
  final String username;
  final UserModel user;
  final double consumedCalories;
  final double consumedProtein;
  final double consumedNutrients;
  final double caloriesProgress;
  final double proteinProgress;
  final double nutrientsProgress;

  final Function({
  required double cal,
  required double prot,
  required double nut,
  }) onUpdateProgress;
  final VoidCallback onResetProgress;

  const Home({
    super.key,
    required this.username,
    required this.user,
    required this.consumedCalories,
    required this.consumedProtein,
    required this.consumedNutrients,
    required this.caloriesProgress,
    required this.proteinProgress,
    required this.nutrientsProgress,
    required this.onUpdateProgress,
    required this.onResetProgress,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAddOpen = false;
  bool isSearchOpen = false;
  final TextEditingController caloriesController = TextEditingController();
  final TextEditingController proteinController = TextEditingController();
  final TextEditingController nutrientsController = TextEditingController();
  final TextEditingController mealNameController = TextEditingController();
  List a = [];
  // Daily recommended intake (for scaling progress)
  late double dailyCalories;
  late double dailyProtein;
  late double dailyNutrients;

  // For tracking consumed meals
  List<Meal> consumedMeals = [];
  DateTime lastResetTime = DateTime.now();
  Timer? _timer;

  // Step 2: Define a list of common meals
  List<Meal> meals = [
    Meal(name: 'Roti', calories: 100, protein: 3, nutrients: 4),
    Meal(name: 'Rice', calories: 200, protein: 4, nutrients: 6),
    Meal(name: 'Dal', calories: 150, protein: 8, nutrients: 10),
    Meal(name: 'Paneer', calories: 250, protein: 14, nutrients: 12),
    Meal(name: 'Chicken', calories: 300, protein: 27, nutrients: 15),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize goals from user model
    initializeGoals();
    // Load consumed meals and last reset time
    loadConsumedMeals();
    // Set up timer to check for reset every minute
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      checkForReset();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void initializeGoals() {
    // Use values from user model, with fallbacks to default values
    dailyCalories =
    widget.user.claories > 0 ? widget.user.claories.toDouble() : 2000.0;
    dailyProtein =
    widget.user.protient > 0 ? widget.user.protient.toDouble() : 50.0;
    dailyNutrients =
    widget.user.nutrients > 0 ? widget.user.nutrients.toDouble() : 100.0;
  }

  // Function to save consumed meals to SharedPreferences
  Future<void> saveConsumedMeals() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> mealsJson = consumedMeals
        .map((meal) => meal.toMap().toString())
        .toList();
    await prefs.setStringList('consumed_meals', mealsJson);
    await prefs.setInt('last_reset_time', lastResetTime.millisecondsSinceEpoch);
  }

  // Function to load consumed meals from SharedPreferences
  Future<void> loadConsumedMeals() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? mealsJson = prefs.getStringList('consumed_meals');
    final int? lastResetTimeMs = prefs.getInt('last_reset_time');

    if (lastResetTimeMs != null) {
      lastResetTime = DateTime.fromMillisecondsSinceEpoch(lastResetTimeMs);
    }

    if (mealsJson != null) {
      // We would need to properly parse the string representation of the map
      // This is simplified for now
      // In a real implementation, you'd use json.encode/decode
    }

    // Check if we need to reset immediately
    checkForReset();
  }

  // Function to check if 24 hours have passed since last reset
  void checkForReset() {
    final now = DateTime.now();
    if (now.difference(lastResetTime).inHours >= 24) {
      resetProgress();
    }
  }

  // Function to manually reset progress and update reset time
  void resetProgress() {
    setState(() {
      consumedMeals.clear();
      lastResetTime = DateTime.now();
    });
    widget.onResetProgress();
    saveConsumedMeals();
  }

  // Function to add a meal to consumed meals
  void addConsumedMeal(String name, double calories, double protein, double nutrients) {
    final meal = Meal(
      name: name,
      calories: calories,
      protein: protein,
      nutrients: nutrients,
    );

    setState(() {
      consumedMeals.add(meal);
    });

    saveConsumedMeals();
  }

  // Function to add meal from search
  void addMealFromSearch(Map<String, dynamic> nutritionData) {

    final String foodName = mealNameController.text;

    final double calories = nutritionData['calories']?.toDouble() ?? 0.0;
    final double protein = nutritionData['protein']?.toDouble() ?? 0.0;
    final double nutrients = nutritionData['fiber']?.toDouble() ?? 0.0;

    widget.onUpdateProgress(
      cal: calories,
      prot: protein,
      nut: nutrients,
    );


    addConsumedMeal(foodName, calories, protein, nutrients);
  }

  // Function to add a custom meal
  void addCustomMeal() {
    if (mealNameController.text.isNotEmpty &&
        caloriesController.text.isNotEmpty &&
        proteinController.text.isNotEmpty &&
        nutrientsController.text.isNotEmpty) {

      final String name = mealNameController.text;
      final double calories = double.parse(caloriesController.text);
      final double protein = double.parse(proteinController.text);
      final double nutrients = double.parse(nutrientsController.text);

      widget.onUpdateProgress(
        cal: calories,
        prot: protein,
        nut: nutrients,
      );

      addConsumedMeal(name, calories, protein, nutrients);

      setState(() {
        isAddOpen = false;
      });

      // Clear the controllers
      mealNameController.clear();
      caloriesController.clear();
      proteinController.clear();
      nutrientsController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome, ${widget.username}!"),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              setState(() {
                isSearchOpen = !isSearchOpen;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: resetProgress,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            isAddOpen = true;
          });
        },
        child: Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (isSearchOpen)
              SizedBox(
                height: 400, // Fixed height for search container
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Search Food",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  isSearchOpen = false;
                                });
                              },
                            ),
                          ],
                        ),
                        Expanded(
                          child: FoodSearchWidget(
                            onFoodSelected: (nutritionData) {
                              addMealFromSearch(nutritionData);
                              setState(() {
                                isSearchOpen = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Food added to your daily intake',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (isAddOpen)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Add Custom Meal",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                isAddOpen = false;
                              });
                            },
                          ),
                        ],
                      ),
                      TextField(
                        controller: mealNameController,
                        decoration: InputDecoration(labelText: "Meal Name"),
                      ),
                      TextField(
                        controller: caloriesController,
                        decoration: InputDecoration(labelText: "Calories"),
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: proteinController,
                        decoration: InputDecoration(labelText: "Protein (g)"),
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: nutrientsController,
                        decoration: InputDecoration(labelText: "Nutrients (%)"),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: addCustomMeal,
                        child: Text("Add Meal"),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Daily Progress",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),

                    // Show daily goals from profile
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Your Daily Goals",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "Calories: ${dailyCalories.toStringAsFixed(0)} kcal",
                              style: TextStyle(color: Colors.red),
                            ),
                            Text(
                              "Protein: ${dailyProtein.toStringAsFixed(0)} g",
                              style: TextStyle(color: Colors.blue),
                            ),
                            Text(
                              "Nutrients: ${dailyNutrients.toStringAsFixed(0)}%",
                              style: TextStyle(color: Colors.green),
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  "Next reset: ${_formatNextResetTime()}",
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Progress bars
                    _buildProgressSection(),

                    SizedBox(height: 20),

                    // Consumed meals list
                    _buildConsumedMealsList(),

                    SizedBox(height: 10),

                    // Quick add from common meals
                    _buildCommonMealsSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Format the next reset time
  String _formatNextResetTime() {
    final nextReset = lastResetTime.add(Duration(hours: 24));
    final now = DateTime.now();
    final hours = nextReset.difference(now).inHours;
    final minutes = nextReset.difference(now).inMinutes % 60;

    return "$hours h $minutes min";
  }

  // Progress bars widget
  Widget _buildProgressSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today's Progress",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 10),
            _buildProgressBar(
              "Calories",
              widget.caloriesProgress,
              widget.consumedCalories,
              dailyCalories,
              Colors.red,
            ),
            SizedBox(height: 8),
            _buildProgressBar(
              "Protein",
              widget.proteinProgress,
              widget.consumedProtein,
              dailyProtein,
              Colors.blue,
            ),
            SizedBox(height: 8),
            _buildProgressBar(
              "Nutrients",
              widget.nutrientsProgress,
              widget.consumedNutrients,
              dailyNutrients,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  // Individual progress bar
  Widget _buildProgressBar(String label, double progress, double consumed, double total, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text("$label: "),
            Text(
              "${consumed.toStringAsFixed(1)} / ${total.toStringAsFixed(0)}",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 10,
        ),
      ],
    );
  }

  // Consumed meals list widget
  Widget _buildConsumedMealsList() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Today's Meals",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  DateFormat('EEE, MMM d').format(DateTime.now()),
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            consumedMeals.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "No meals logged today",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: consumedMeals.length,
              itemBuilder: (context, index) {
                final meal = consumedMeals[index];
                return ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 0),
                  title: Text(meal.name),
                  subtitle: Text(
                      "${meal.calories.toStringAsFixed(0)} cal • ${meal.protein.toStringAsFixed(1)}g protein • ${DateFormat.jm().format(meal.timestamp)}"
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red[300]),
                    onPressed: () {
                      setState(() {
                        // Subtract the values before removing
                        widget.onUpdateProgress(
                          cal: -meal.calories,
                          prot: -meal.protein,
                          nut: -meal.nutrients,
                        );
                        consumedMeals.removeAt(index);
                        saveConsumedMeals();
                      });
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Common meals for quick adding
  Widget _buildCommonMealsSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Quick Add Common Meals",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: meals.map((meal) {
                return ActionChip(
                  label: Text(meal.name),
                  avatar: CircleAvatar(
                    backgroundColor: Colors.green[700],
                    child: Text(
                      meal.calories.toStringAsFixed(0),
                      style: TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                  onPressed: () {
                    widget.onUpdateProgress(
                      cal: meal.calories,
                      prot: meal.protein,
                      nut: meal.nutrients,
                    );
                    addConsumedMeal(
                        meal.name,
                        meal.calories,
                        meal.protein,
                        meal.nutrients
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added ${meal.name} to your meals'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}