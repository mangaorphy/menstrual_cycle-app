import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  // Callback to notify other providers of auth changes
  Function(String?)? _onAuthStateChanged;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _initializeAuth();
  }

  // Set callback for auth state changes
  void setAuthStateChangeCallback(Function(String?) callback) {
    _onAuthStateChanged = callback;
  }

  void _initializeAuth() {
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      _saveUserData();

      // Notify other providers of auth state change
      if (_onAuthStateChanged != null) {
        _onAuthStateChanged!(_user?.uid);
      }

      notifyListeners();
    });
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (_user != null) {
      await prefs.setString('user_email', _user!.email ?? '');
      await prefs.setString('user_id', _user!.uid);
      await prefs.setBool('is_logged_in', true);
    } else {
      await prefs.remove('user_email');
      await prefs.remove('user_id');
      await prefs.setBool('is_logged_in', false);
    }
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();

      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );

      _user = userCredential.user;
      await _saveUserData();

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      _setError(_getErrorMessage(e.code));
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('An unexpected error occurred. Please try again.');
      return false;
    }
  }

  Future<bool> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      _setLoading(true);
      _clearError();

      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );

      _user = userCredential.user;

      // Send email verification
      if (_user != null && !_user!.emailVerified) {
        await _user!.sendEmailVerification();
      }

      await _saveUserData();

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      _setError(_getErrorMessage(e.code));
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('An unexpected error occurred. Please try again.');
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      _clearError();

      await _auth.signOut();
      _user = null;
      await _saveUserData();

      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _setError('Error signing out. Please try again.');
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _setLoading(true);
      _clearError();

      await _auth.sendPasswordResetEmail(email: email.trim());

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      _setError(_getErrorMessage(e.code));
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('An unexpected error occurred. Please try again.');
      return false;
    }
  }

  Future<void> updateUserProfile({String? displayName}) async {
    if (_user != null) {
      try {
        await _user!.updateDisplayName(displayName);
        await _user!.reload();
        _user = _auth.currentUser;
        await _saveUserData();
        notifyListeners();
      } catch (e) {
        _setError('Error updating profile. Please try again.');
      }
    }
  }

  Future<bool> deleteUser() async {
    if (_user != null) {
      try {
        _setLoading(true);
        _clearError();

        await _user!.delete();
        _user = null;
        await _saveUserData();

        _setLoading(false);
        return true;
      } on FirebaseAuthException catch (e) {
        _setLoading(false);
        _setError(_getErrorMessage(e.code));
        return false;
      } catch (e) {
        _setLoading(false);
        _setError('An unexpected error occurred. Please try again.');
        return false;
      }
    }
    return false;
  }

  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'requires-recent-login':
        return 'Please log out and log back in to perform this action.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  // Get user data from SharedPreferences (useful for offline state)
  Future<Map<String, String?>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'email': prefs.getString('user_email'),
      'user_id': prefs.getString('user_id'),
      'is_logged_in': prefs.getBool('is_logged_in')?.toString(),
    };
  }
}
