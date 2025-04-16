import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_project/model/usermodel.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  // Sign up with email and password
  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    try {
      // Create the user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Failed to create user');
      }
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  // Save user data to Firestore
  Future<void> saveUserData(UserModel user) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      final userData = {
        'name': user.name,
        'email': user.email,
        'weight': user.wieght,
        'height': user.hieght,
        'calories': user.claories,
        'protein': user.protient,
        'nutrients': user.nutrients,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .set(userData, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save user data: $e');
    }
  }

  // Get user data from Firestore
  Future<UserModel> getUserData(String email) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('Error: No authenticated user found when getting user data');
        throw Exception('No authenticated user found');
      }

      print('Getting user data for user ID: ${currentUser.uid}');
      final doc =
          await _firestore.collection('users').doc(currentUser.uid).get();

      if (!doc.exists) {
        print('Error: User document not found in Firestore');
        throw Exception('User data not found');
      }

      final data = doc.data();
      if (data == null) {
        print('Error: User data is empty');
        throw Exception('User data is empty');
      }

      print('Successfully retrieved user data: $data');
      return UserModel(
        name: data['name'] as String? ?? '',
        email: data['email'] as String? ?? '',
        password: '',
        wieght: (data['weight'] as num?)?.toInt() ?? 0,
        hieght: (data['height'] as num?)?.toInt() ?? 0,
        claories: (data['calories'] as num?)?.toInt() ?? 0,
        protient: (data['protein'] as num?)?.toInt() ?? 0,
        nutrients: (data['nutrients'] as num?)?.toInt() ?? 0,
      );
    } catch (e, stackTrace) {
      print('Error getting user data: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to get user data: $e');
    }
  }

  // Update user data
  Future<void> updateUserData(UserModel user) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      await _firestore.collection('users').doc(currentUser.uid).update({
        'weight': user.wieght,
        'height': user.hieght,
        'calories': user.claories,
        'protein': user.protient,
        'nutrients': user.nutrients,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update user data: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      print('Attempting to sign out user');
      await _auth.signOut();
      print('Successfully signed out user');
    } catch (e, stackTrace) {
      print('Error signing out: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to sign out: $e');
    }
  }
}
