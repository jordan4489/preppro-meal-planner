import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Check if user is logged in
  static bool get isLoggedIn => _auth.currentUser != null;

  // Auth state stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Ensure auth persistence (especially on web)
  static Future<void> ensurePersistence() async {
    if (kIsWeb) {
      await _auth.setPersistence(Persistence.LOCAL);
    }
  }

  // Sign up with email and password
  static Future<String?> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      await ensurePersistence();
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ).timeout(const Duration(seconds: 30));

      await userCredential.user?.updateDisplayName(displayName);

      // Create user document in Firestore (non-blocking)
      _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'displayName': displayName,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }).catchError((error) {
        print('Firestore user document creation failed: $error');
      });

      return null; // Success
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      return e.message ?? 'Sign up failed';
    } catch (e) {
      print('Sign up error: $e');
      return 'Connection error. Check your internet and try again.';
    }
  }

  // Sign in with email and password
  static Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await ensurePersistence();
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      ).timeout(const Duration(seconds: 30));
      return null; // Success
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      return e.message ?? 'Sign in failed';
    } catch (e) {
      print('Sign in error: $e');
      return 'Connection error. Check your internet and try again.';
    }
  }

  // Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // Password reset
  static Future<String?> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Password reset failed';
    }
  }

  // Update user profile
  static Future<String?> updateProfile({
    required String displayName,
  }) async {
    try {
      await _auth.currentUser?.updateDisplayName(displayName);
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .update({'displayName': displayName, 'updatedAt': FieldValue.serverTimestamp()});
      return null; // Success
    } catch (e) {
      return 'Update failed: $e';
    }
  }
}
