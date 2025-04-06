import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_project/model/usermodel.dart';

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
}

class Home extends StatefulWidget {
  final String username;
  final UserModel user; // Pass user model from profile

  const Home({
    super.key,
    required this.username,
    required this.user,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double caloriesProgress = 0.0;
  double proteinProgress = 0.0;
  double nutrientsProgress = 0.0;
  bool isAddOpen = false;
  String lastResetDate = '';

  // Current consumed values
  double consumedCalories = 0.0;
  double consumedProtein = 0.0;
  double consumedNutrients = 0.0;

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
    // Load current progress or reset if needed
    loadProgress();
  }

  void initializeGoals() {
    // Use values from user model, with fallbacks to default values
    dailyCalories = widget.user.claories > 0 ? widget.user.claories.toDouble() : 2000.0;
    dailyProtein = widget.user.protient > 0 ? widget.user.protient.toDouble() : 50.0;
    dailyNutrients = widget.user.nutrients > 0 ? widget.user.nutrients.toDouble() : 100.0;
  }

  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();

    // Get current date in format YYYY-MM-DD
    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Get last reset date
    String savedDate = prefs.getString('lastResetDate') ?? '';

    // If it's a new day or first time, reset progress
    if (savedDate != currentDate) {
      await resetProgress(currentDate);
    } else {
      // Otherwise load saved progress
      setState(() {
        consumedCalories = prefs.getDouble('consumedCalories') ?? 0.0;
        consumedProtein = prefs.getDouble('consumedProtein') ?? 0.0;
        consumedNutrients = prefs.getDouble('consumedNutrients') ?? 0.0;

        // Calculate progress based on consumed values and daily goals
        caloriesProgress = dailyCalories > 0 ? (consumedCalories / dailyCalories).clamp(0.0, 1.0) : 0.0;
        proteinProgress = dailyProtein > 0 ? (consumedProtein / dailyProtein).clamp(0.0, 1.0) : 0.0;
        nutrientsProgress = dailyNutrients > 0 ? (consumedNutrients / dailyNutrients).clamp(0.0, 1.0) : 0.0;

        lastResetDate = savedDate;
      });
    }
  }

  Future<void> resetProgress(String currentDate) async {
    final prefs = await SharedPreferences.getInstance();

    // Reset all progress values
    setState(() {
      consumedCalories = 0.0;
      consumedProtein = 0.0;
      consumedNutrients = 0.0;
      caloriesProgress = 0.0;
      proteinProgress = 0.0;
      nutrientsProgress = 0.0;
      lastResetDate = currentDate;
    });

    // Save reset state
    await prefs.setString('lastResetDate', currentDate);
    await prefs.setDouble('consumedCalories', 0.0);
    await prefs.setDouble('consumedProtein', 0.0);
    await prefs.setDouble('consumedNutrients', 0.0);
  }

  Future<void> saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('consumedCalories', consumedCalories);
    await prefs.setDouble('consumedProtein', consumedProtein);
    await prefs.setDouble('consumedNutrients', consumedNutrients);
  }

  void updateProgress({required double cal, required double prot, required double nut}) {
    setState(() {
      // Update consumed values
      consumedCalories += cal;
      consumedProtein += prot;
      consumedNutrients += nut;

      // Update progress bars
      caloriesProgress = dailyCalories > 0 ? (consumedCalories / dailyCalories).clamp(0.0, 1.0) : 0.0;
      proteinProgress = dailyProtein > 0 ? (consumedProtein / dailyProtein).clamp(0.0, 1.0) : 0.0;
      nutrientsProgress = dailyNutrients > 0 ? (consumedNutrients / dailyNutrients).clamp(0.0, 1.0) : 0.0;
    });

    // Save the updated progress
    saveProgress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome, ${widget.username}!"),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () async {
              String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
              await resetProgress(currentDate);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Progress reset to zero")),
              );
            },
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Daily Progress", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),

              // Show daily goals from profile
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Your Daily Goals",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      SizedBox(height: 5),
                      Text("Calories: ${dailyCalories.toStringAsFixed(0)} kcal",
                          style: TextStyle(color: Colors.red)),
                      Text("Protein: ${dailyProtein.toStringAsFixed(0)} g",
                          style: TextStyle(color: Colors.blue)),
                      Text("Nutrients: ${dailyNutrients.toStringAsFixed(0)}%",
                          style: TextStyle(color: Colors.green)),
                      SizedBox(height: 5),
                      Text("Progress will reset at midnight",
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              Text("Calories (${consumedCalories.toStringAsFixed(0)}/${dailyCalories.toStringAsFixed(0)} kcal)",
                  style: TextStyle(fontSize: 16)),
              LinearProgressIndicator(
                value: caloriesProgress,
                minHeight: 10,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
              ),
              SizedBox(height: 20),

              Text("Protein (${consumedProtein.toStringAsFixed(0)}/${dailyProtein.toStringAsFixed(0)} g)",
                  style: TextStyle(fontSize: 16)),
              LinearProgressIndicator(
                value: proteinProgress,
                minHeight: 10,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              SizedBox(height: 20),

              Text("Nutrients (${consumedNutrients.toStringAsFixed(0)}/${dailyNutrients.toStringAsFixed(0)}%)",
                  style: TextStyle(fontSize: 16)),
              LinearProgressIndicator(
                value: nutrientsProgress,
                minHeight: 10,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
              SizedBox(height: 30),

              Text('Mostly Consumed Meals', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),

              // Step 3: Meal Tiles
              Column(
                children: meals.map((meal) {
                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(meal.name),
                      subtitle: Text(
                          "Calories: ${meal.calories}, Protein: ${meal.protein}g, Nutrients: ${meal.nutrients}"),
                      trailing: IconButton(
                        icon: Icon(Icons.add_circle_outline, color: Colors.green),
                        onPressed: () {
                          updateProgress(
                            cal: meal.calories,
                            prot: meal.protein,
                            nut: meal.nutrients,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Added ${meal.name} to today's intake"),
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
                Text('Add Custom Intake', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                    double cal = double.tryParse(caloriesController.text) ?? 0;
                    double prot = double.tryParse(proteinController.text) ?? 0;
                    double nut = double.tryParse(nutrientsController.text) ?? 0;

                    updateProgress(cal: cal, prot: prot, nut: nut);

                    caloriesController.clear();
                    proteinController.clear();
                    nutrientsController.clear();
                    setState(() {
                      isAddOpen = false;
                    });
                  },
                  child: Text("Update"),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}