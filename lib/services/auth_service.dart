import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserModel> signIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('User not found');
      }

      final userData = await _firestore
          .collection(_collection)
          .doc(userCredential.user!.uid)
          .get();

      if (!userData.exists) {
        throw Exception('User data not found');
      }

      return UserModel.fromMap({
        ...userData.data()!,
        'id': userData.id,
      });
    } catch (e) {
      debugPrint('Error signing in: $e');
      rethrow;
    }
  }

  // Register with email and password
  Future<UserModel> signUp(
    String fullName,
    String email,
    String phoneNumber,
    String password,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Failed to create user');
      }

      final user = UserModel(
        id: userCredential.user!.uid,
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        profileImage: null,
      );

      await _firestore
          .collection(_collection)
          .doc(userCredential.user!.uid)
          .set(user.toMap());

      return user;
    } catch (e) {
      debugPrint('Error signing up: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }

  // Get user data
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        debugPrint('Firestore User Data Type: ${data.runtimeType}');
        debugPrint('Firestore User Data: $data');
        return UserModel.fromMap(data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user data: $e');
      rethrow;
    }
  }

  // Update user profile
  Future<UserModel> updateProfile(String fullName, String phoneNumber) async {
    try {
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final userData = await _firestore
          .collection(_collection)
          .doc(currentUser!.uid)
          .get();

      if (!userData.exists) {
        throw Exception('User data not found');
      }

      final user = UserModel.fromMap({
        ...userData.data()!,
        'id': userData.id,
      });

      final updatedUser = user.copyWith(
        fullName: fullName,
        phoneNumber: phoneNumber,
        updatedAt: DateTime.now(),
        profileImage: user.profileImage,
      );

      await _firestore
          .collection(_collection)
          .doc(currentUser!.uid)
          .update(updatedUser.toMap());

      return updatedUser;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      rethrow;
    }
  }

  // Mendapatkan daftar semua pengguna (untuk admin)
  Future<List<UserModel>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs.map((doc) {
        return UserModel.fromMap({
          ...doc.data()!,
          'id': doc.id,
        });
      }).toList();
    } catch (e) {
      debugPrint('Error getting all users: $e');
      rethrow;
    }
  }
} 