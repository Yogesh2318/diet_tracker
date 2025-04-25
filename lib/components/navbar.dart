import 'package:flutter/material.dart';
import 'package:my_project/model/usermodel.dart';
import 'package:my_project/pages/home.dart';
import 'package:my_project/pages/profile.dart';
import 'package:my_project/pages/search.dart';
import 'package:my_project/pages/camera.dart';
import 'package:my_project/services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Navbar extends StatefulWidget {
  final String username;

  const Navbar({super.key, required this.username});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int _selectedIndex = 0;
  late UserModel userModel;
  final _firebaseService = FirebaseService();
  final _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;

  // Progress tracking state
  double consumedCalories = 0.0;
  double consumedProtein = 0.0;
  double consumedNutrients = 0.0;
  double caloriesProgress = 0.0;
  double proteinProgress = 0.0;
  double nutrientsProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await _firebaseService.getUserData(widget.username);
      setState(() {
        userModel = user;
        _isLoading = false;
      });
      // Load progress after user data is loaded
      await _loadProgress();
    } catch (e) {
      print('Error loading user data: $e');
      // Initialize with default values if loading fails
      userModel = UserModel(
        name: widget.username,
        email: '',
        password: '',
        wieght: 0,
        hieght: 0,
        claories: 2000,
        protient: 50,
        nutrients: 100,
      );
      _isLoading = false;
      // Still try to load progress even if user data fails
      await _loadProgress();
    }
  }

  Future<void> _loadProgress() async {
    final currentUser = _firebaseService.currentUser;
    if (currentUser == null) return;

    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      final doc =
          await _firestore
              .collection('users')
              .doc(currentUser.uid)
              .collection('daily_progress')
              .doc(currentDate)
              .get();

      if (!doc.exists) {
        // Check if there's any progress for today
        final todayDocs =
            await _firestore
                .collection('users')
                .doc(currentUser.uid)
                .collection('daily_progress')
                .where('date', isEqualTo: currentDate)
                .get();

        if (todayDocs.docs.isEmpty) {
          // No progress for today, create new document
          await _resetProgress(currentDate);
        } else {
          // Use the first document found for today
          final data = todayDocs.docs.first.data();
          _updateProgressFromData(data);
        }
      } else {
        // Use the document found
        final data = doc.data();
        if (data != null) {
          _updateProgressFromData(data);
        }
      }
    } catch (e) {
      print('Error loading progress: $e');
      await _resetProgress(currentDate);
    }
  }

  void _updateProgressFromData(Map<String, dynamic> data) {
    setState(() {
      consumedCalories = (data['calories'] as num?)?.toDouble() ?? 0.0;
      consumedProtein = (data['protein'] as num?)?.toDouble() ?? 0.0;
      consumedNutrients = (data['nutrients'] as num?)?.toDouble() ?? 0.0;

      caloriesProgress =
          userModel.claories > 0
              ? (consumedCalories / userModel.claories).clamp(0.0, 1.0)
              : 0.0;
      proteinProgress =
          userModel.protient > 0
              ? (consumedProtein / userModel.protient).clamp(0.0, 1.0)
              : 0.0;
      nutrientsProgress =
          userModel.nutrients > 0
              ? (consumedNutrients / userModel.nutrients).clamp(0.0, 1.0)
              : 0.0;
    });
  }

  Future<void> _resetProgress(String currentDate) async {
    final currentUser = _firebaseService.currentUser;
    if (currentUser == null) return;

    setState(() {
      consumedCalories = 0.0;
      consumedProtein = 0.0;
      consumedNutrients = 0.0;
      caloriesProgress = 0.0;
      proteinProgress = 0.0;
      nutrientsProgress = 0.0;
    });

    try {
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('daily_progress')
          .doc(currentDate)
          .set({
            'calories': 0.0,
            'protein': 0.0,
            'nutrients': 0.0,
            'date': currentDate,
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      print('Error resetting progress: $e');
    }
  }

  Future<void> _saveProgress() async {
    final currentUser = _firebaseService.currentUser;
    if (currentUser == null) return;

    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('daily_progress')
          .doc(currentDate)
          .set({
            'calories': consumedCalories,
            'protein': consumedProtein,
            'nutrients': consumedNutrients,
            'date': currentDate,
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      print('Error saving progress: $e');
    }
  }

  void updateProgress({
    required double cal,
    required double prot,
    required double nut,
  }) {
    setState(() {
      consumedCalories += cal;
      consumedProtein += prot;
      consumedNutrients += nut;

      caloriesProgress =
          userModel.claories > 0
              ? (consumedCalories / userModel.claories).clamp(0.0, 1.0)
              : 0.0;
      proteinProgress =
          userModel.protient > 0
              ? (consumedProtein / userModel.protient).clamp(0.0, 1.0)
              : 0.0;
      nutrientsProgress =
          userModel.nutrients > 0
              ? (consumedNutrients / userModel.nutrients).clamp(0.0, 1.0)
              : 0.0;
    });

    _saveProgress();
  }

  // Method to update the shared user model
  Future<void> updateUserModel(UserModel updatedUser) async {
    try {
      // Update Firestore
      await _firebaseService.updateUserData(updatedUser);

      // Update local state
      setState(() {
        userModel = updatedUser;
      });
    } catch (e) {
      print('Error updating user data: $e');
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final List<Widget> _pages = [
      Home(
        username: widget.username,
        user: userModel,
        consumedCalories: consumedCalories,
        consumedProtein: consumedProtein,
        consumedNutrients: consumedNutrients,
        caloriesProgress: caloriesProgress,
        proteinProgress: proteinProgress,
        nutrientsProgress: nutrientsProgress,
        onUpdateProgress: updateProgress,
        onResetProgress:
            () =>
                _resetProgress(DateFormat('yyyy-MM-dd').format(DateTime.now())),
      ),
      const SearchPage(),
      ProfilePage(user: userModel, onUpdate: updateUserModel),
      CameraScreen(),
    ];

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.camera), label: 'Camera'),
          
        ],
      ),
    );
  }
}
