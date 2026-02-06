import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    await AuthService.ensurePersistence();

    // Check current user immediately on initialization
    _user = AuthService.currentUser;
    notifyListeners();

    // Listen for future changes
    AuthService.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final error = await AuthService.signUp(
      email: email,
      password: password,
      displayName: displayName,
    );

    _isLoading = false;
    if (error != null) {
      _error = error;
    }
    notifyListeners();
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final error = await AuthService.signIn(
      email: email,
      password: password,
    );

    _isLoading = false;
    if (error != null) {
      _error = error;
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    await AuthService.signOut();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final error = await AuthService.resetPassword(email: email);

    _isLoading = false;
    if (error != null) {
      _error = error;
    }
    notifyListeners();
  }

  Future<void> updateProfile(String displayName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final error = await AuthService.updateProfile(displayName: displayName);

    _isLoading = false;
    if (error != null) {
      _error = error;
    }
    notifyListeners();
  }
}
