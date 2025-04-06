import 'package:flutter/material.dart';
import 'package:my_project/model/usermodel.dart';

class ProfilePage extends StatefulWidget {
  final UserModel user;
  final Function(UserModel) onUpdate;

  const ProfilePage({
    Key? key,
    required this.user,
    required this.onUpdate,
  }) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditing = false;

  // TextEditingControllers for user inputs
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController caloriesController = TextEditingController();
  final TextEditingController proteinController = TextEditingController();
  final TextEditingController nutrientsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current values from the passed user model
    heightController.text = widget.user.hieght.toString();
    weightController.text = widget.user.wieght.toString();
    caloriesController.text = widget.user.claories.toString();
    proteinController.text = widget.user.protient.toString();
    nutrientsController.text = widget.user.nutrients.toString();
  }

  void toggleEditMode() {
    setState(() {
      isEditing = !isEditing;
      if (!isEditing) {
        // Save data when exiting edit mode
        saveData();
      }
    });
  }

  void saveData() {
    // Update the local user model
    setState(() {
      widget.user.hieght = int.tryParse(heightController.text) ?? widget.user.hieght;
      widget.user.wieght = int.tryParse(weightController.text) ?? widget.user.wieght;
      widget.user.claories = int.tryParse(caloriesController.text) ?? widget.user.claories;
      widget.user.protient = int.tryParse(proteinController.text) ?? widget.user.protient;
      widget.user.nutrients = int.tryParse(nutrientsController.text) ?? widget.user.nutrients;
    });

    // Notify the parent (Navbar) about the update
    widget.onUpdate(widget.user);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Profile updated successfully!"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Rest of your ProfilePage implementation remains the same
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
            onPressed: toggleEditMode,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header with avatar and user info
            Container(
              padding: EdgeInsets.all(24),
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    widget.user.name,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.user.email,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // Stats section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      "Personal Stats",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 8),

                  // Display stats in cards or edit fields based on mode
                  buildStatItem(
                      "Height",
                      "${widget.user.hieght} cm",
                      heightController,
                      "cm",
                      Icons.height
                  ),
                  buildStatItem(
                      "Weight",
                      "${widget.user.wieght} kg",
                      weightController,
                      "kg",
                      Icons.fitness_center
                  ),

                  SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      "Nutrition Goals",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 8),

                  buildStatItem(
                      "Daily Calories",
                      "${widget.user.claories} kcal",
                      caloriesController,
                      "kcal",
                      Icons.local_fire_department
                  ),
                  buildStatItem(
                      "Protein Target",
                      "${widget.user.protient} g",
                      proteinController,
                      "g",
                      Icons.egg_alt
                  ),
                  buildStatItem(
                      "Nutrients Goal",
                      "${widget.user.nutrients}%",
                      nutrientsController,
                      "%",
                      Icons.food_bank
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStatItem(String label, String value, TextEditingController controller, String unit, IconData icon) {
    // Implementation remains the same as in your improved profile page
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  isEditing
                      ? TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Enter $label",
                      suffixText: unit,
                      contentPadding: EdgeInsets.symmetric(vertical: 4),
                    ),
                  )
                      : Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}