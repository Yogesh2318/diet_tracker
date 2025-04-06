import 'package:flutter/material.dart';
import 'package:my_project/model/usermodel.dart';
import 'package:my_project/pages/home.dart';
import 'package:my_project/pages/profile.dart';
import 'package:my_project/pages/search.dart';

class Navbar extends StatefulWidget {
  final String username;

  const Navbar({super.key, required this.username});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int _selectedIndex = 0;

  // Create a shared UserModel instance that will be passed to both pages
  late UserModel userModel;

  @override
  void initState() {
    super.initState();
    // Initialize with default values and the username from login
    userModel = UserModel(
      name: widget.username,
      email: "yvbhivasne@gmail.com", // You might want to pass this from login too
      password: "123456",
      wieght: 0,
      hieght: 0,
      claories: 2000, // Default values
      protient: 50,
      nutrients: 100,
    );
  }

  // Method to update the shared user model (called from ProfilePage)
  void updateUserModel(UserModel updatedUser) {
    setState(() {
      userModel = updatedUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Pages initialized inside build with shared userModel
    final List<Widget> _pages = [
      Home(
        username: widget.username,
        user: userModel, // Pass the shared user model to Home
      ),
      const SearchPage(),
      ProfilePage(
        user: userModel, // Pass the shared user model to Profile
        onUpdate: updateUserModel, // Pass the update callback
      ),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Search",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}