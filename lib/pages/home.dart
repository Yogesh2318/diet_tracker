import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_project/model/usermodel.dart';
import 'package:my_project/services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/food_search.dart';

// Step 1: Create a Meal class
class Meal {
  final String name;
  final double calories;
  final double protein;
  final double nutrients;

  Meal({
    required this.name,
    required this.calories,
    required this.protein,
    required this.nutrients,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'calories': calories,
      'protein': protein,
      'nutrients': nutrients,
    };
  }

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      name: map['name'] as String,
      calories: (map['calories'] as num).toDouble(),
      protein: (map['protein'] as num).toDouble(),
      nutrients: (map['nutrients'] as num).toDouble(),
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
  })
  onUpdateProgress;
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

  // Daily recommended intake (for scaling progress)
  late double dailyCalories;
  late double dailyProtein;
  late double dailyNutrients;

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
            onPressed: widget.onResetProgress,
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
                              widget.onUpdateProgress(
                                cal: nutritionData['calories'].toDouble(),
                                prot: nutritionData['protein'].toDouble(),
                                nut: nutritionData['fiber'].toDouble(),
                              );
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
                            Text(
                              "Progress will reset at midnight",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    Text(
                      "Calories (${widget.consumedCalories.toStringAsFixed(0)}/${dailyCalories.toStringAsFixed(0)} kcal)",
                      style: TextStyle(fontSize: 16),
                    ),
                    LinearProgressIndicator(
                      value: widget.caloriesProgress,
                      minHeight: 10,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    ),
                    SizedBox(height: 20),

                    Text(
                      "Protein (${widget.consumedProtein.toStringAsFixed(0)}/${dailyProtein.toStringAsFixed(0)} g)",
                      style: TextStyle(fontSize: 16),
                    ),
                    LinearProgressIndicator(
                      value: widget.proteinProgress,
                      minHeight: 10,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    SizedBox(height: 20),

                    Text(
                      "Nutrients (${widget.consumedNutrients.toStringAsFixed(0)}/${dailyNutrients.toStringAsFixed(0)}%)",
                      style: TextStyle(fontSize: 16),
                    ),
                    LinearProgressIndicator(
                      value: widget.nutrientsProgress,
                      minHeight: 10,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                    SizedBox(height: 30),

                    Text(
                      'Mostly Consumed Meals',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),

                    // Step 3: Meal Tiles
                    Column(
                      children:
                          meals.map((meal) {
                            return Card(
                              elevation: 2,
                              margin: EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                title: Text(meal.name),
                                subtitle: Text(
                                  "Calories: ${meal.calories}, Protein: ${meal.protein}g, Nutrients: ${meal.nutrients}",
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.add_circle_outline,
                                    color: Colors.green,
                                  ),
                                  onPressed: () {
                                    widget.onUpdateProgress(
                                      cal: meal.calories,
                                      prot: meal.protein,
                                      nut: meal.nutrients,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Added ${meal.name} to today's intake",
                                        ),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                    SizedBox(height: 30),

                    if (isAddOpen) ...[
                      Text(
                        'Add Custom Intake',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: caloriesController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Add Calories",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: proteinController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Add Protein",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: nutrientsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Add Nutrients",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          double cal =
                              double.tryParse(caloriesController.text) ?? 0;
                          double prot =
                              double.tryParse(proteinController.text) ?? 0;
                          double nut =
                              double.tryParse(nutrientsController.text) ?? 0;

                          widget.onUpdateProgress(
                            cal: cal,
                            prot: prot,
                            nut: nut,
                          );

                          caloriesController.clear();
                          proteinController.clear();
                          nutrientsController.clear();
                          setState(() {
                            isAddOpen = false;
                          });
                        },
                        child: Text("Update"),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
