import 'package:flutter/material.dart';
import 'package:my_project/model/usermodel.dart';
import 'package:my_project/services/firebase_service.dart';

class ProfilePage extends StatefulWidget {
  final UserModel user;
  final Function(UserModel) onUpdate;

  const ProfilePage({Key? key, required this.user, required this.onUpdate})
    : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditing = false;
  bool _isSaving = false;
  final _firebaseService = FirebaseService();

  // TextEditingControllers for user inputs
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController caloriesController = TextEditingController();
  final TextEditingController proteinController = TextEditingController();
  final TextEditingController nutrientsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    heightController.text = widget.user.hieght.toString();
    weightController.text = widget.user.wieght.toString();
    caloriesController.text = widget.user.claories.toString();
    proteinController.text = widget.user.protient.toString();
    nutrientsController.text = widget.user.nutrients.toString();
  }

  @override
  void dispose() {
    heightController.dispose();
    weightController.dispose();
    caloriesController.dispose();
    proteinController.dispose();
    nutrientsController.dispose();
    super.dispose();
  }

  void toggleEditMode() {
    if (isEditing) {
      // If we're currently editing, save the data
      saveData();
    } else {
      // If we're not editing, enter edit mode
      setState(() {
        isEditing = true;
      });
    }
  }

  Future<void> saveData() async {
    // Show loading indicator
    setState(() {
      _isSaving = true;
    });

    try {
      // Create updated user model
      final updatedUser = widget.user.copyWith(
        hieght: int.tryParse(heightController.text) ?? widget.user.hieght,
        wieght: int.tryParse(weightController.text) ?? widget.user.wieght,
        claories: int.tryParse(caloriesController.text) ?? widget.user.claories,
        protient: int.tryParse(proteinController.text) ?? widget.user.protient,
        nutrients:
            int.tryParse(nutrientsController.text) ?? widget.user.nutrients,
      );

      // Call the update callback
      await widget.onUpdate(updatedUser);

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Exit edit mode
      setState(() {
        isEditing = false;
      });
    } catch (e) {
      // Show error message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    try {
      await _firebaseService.signOut();
      if (!mounted) return;

      // Navigate to login screen
      Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to logout: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
            onPressed: _isSaving ? null : toggleEditMode,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(
                      context,
                    ).primaryColor.withOpacity(0.2),
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.user.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.user.email,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Personal Stats',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  buildStatItem(
                    'Height',
                    '${widget.user.hieght} cm',
                    heightController,
                    'cm',
                    Icons.height,
                  ),
                  buildStatItem(
                    'Weight',
                    '${widget.user.wieght} kg',
                    weightController,
                    'kg',
                    Icons.fitness_center,
                  ),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Nutrition Goals',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  buildStatItem(
                    'Daily Calories',
                    '${widget.user.claories} kcal',
                    caloriesController,
                    'kcal',
                    Icons.local_fire_department,
                  ),
                  buildStatItem(
                    'Protein Target',
                    '${widget.user.protient} g',
                    proteinController,
                    'g',
                    Icons.egg_alt,
                  ),
                  buildStatItem(
                    'Nutrients Goal',
                    '${widget.user.nutrients}%',
                    nutrientsController,
                    '%',
                    Icons.food_bank,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStatItem(
    String label,
    String value,
    TextEditingController controller,
    String unit,
    IconData icon,
  ) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
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
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  isEditing
                      ? TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Enter $label',
                          suffixText: unit,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 4,
                          ),
                        ),
                        enabled: !_isSaving,
                      )
                      : Text(
                        value,
                        style: const TextStyle(
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
