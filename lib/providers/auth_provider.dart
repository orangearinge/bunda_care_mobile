import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/api_error.dart';
import '../services/auth_service.dart';

/// Authentication state enum
enum AuthState {
  initial,        // App just started, checking auth status
  loading,        // Processing auth request
  authenticated,  // User is logged in
  unauthenticated,// User is not logged in
  error,          // Auth error occurred
}

/// Authentication provider using Provider pattern
/// Manages authentication state and user data
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  // State
  AuthState _state = AuthState.initial;
  User? _currentUser;
  String? _errorMessage;
  bool _isGoogleSignInInProgress = false;

  // Getters
  AuthState get state => _state;
  User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == AuthState.loading;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isUnauthenticated => _state == AuthState.unauthenticated;
  bool get isGoogleSignInInProgress => _isGoogleSignInInProgress;

  /// Check if user has complete profile data
  bool get isUserComplete {
    if (_currentUser == null) return false;

    // Check if user has a valid role (not default/empty)
    final validRoles = ['IbuHamil', 'IbuMenyusui', 'Batita'];
    final role = _currentUser!.role?.trim() ?? '';
    return role.isNotEmpty && validRoles.contains(role);
  }

  /// Complete Google sign-in process (called after navigation)
  void completeGoogleSignIn() {
    _setState(AuthState.authenticated);
  }

  /// Update current user role
  Future<void> updateUserRole(String role) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(role: role);
      // Save updated user to storage
      await _authService.updateUser(_currentUser!);
      notifyListeners();
    }
  }





  // ==================== Initialization ====================

  /// Check authentication status on app start
  /// Called from main.dart when app initializes
  Future<void> checkAuthStatus() async {
    _setState(AuthState.initial);

    try {
      // Check if user has stored token
      final isAuth = await _authService.isAuthenticated();

      if (isAuth) {
        // Load user data from storage
        final user = await _authService.getCurrentUser();
        if (user != null) {
          _currentUser = user;
          _setState(AuthState.authenticated);
          return;
        }
      }

      // No valid session
      _setState(AuthState.unauthenticated);
    } catch (e) {
      print('Error checking auth status: $e');
      _setState(AuthState.unauthenticated);
    }
  }

  // ==================== Registration ====================

  /// Register new user with email and password
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setState(AuthState.loading);
    _clearError();

    try {
      final authResponse = await _authService.register(
        name: name,
        email: email,
        password: password,
      );

      _currentUser = authResponse.user;
      _setState(AuthState.authenticated);
      return true;
    } on ApiError catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Registration failed. Please try again.');
      return false;
    }
  }

  // ==================== Login ====================

  /// Login user with email and password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setState(AuthState.loading);
    _clearError();

    try {
      final authResponse = await _authService.login(
        email: email,
        password: password,
      );

      _currentUser = authResponse.user;
      _setState(AuthState.authenticated);
      return true;
    } on ApiError catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Login failed. Please try again.');
      return false;
    }
  }

  // ==================== Google Sign-In ====================

  /// Sign in with Google account
  Future<bool> signInWithGoogle() async {
    _setState(AuthState.loading);
    _clearError();
    _isGoogleSignInInProgress = true;
    notifyListeners();

    try {
      final authResponse = await _authService.signInWithGoogle();

      _currentUser = authResponse.user;
      // Don't set authenticated state immediately - let the UI handle navigation
      _isGoogleSignInInProgress = false;
      notifyListeners();
      return true;
    } on ApiError catch (e) {
      _isGoogleSignInInProgress = false;
      // Don't show error if user cancelled sign-in
      if (e.code != 'GOOGLE_SIGNIN_CANCELLED') {
        _setError(e.message);
      } else {
        _setState(AuthState.unauthenticated);
      }
      return false;
    } catch (e) {
      _isGoogleSignInInProgress = false;
      _setError('Google sign-in failed. Please try again.');
      return false;
    }
  }

  // ==================== Logout ====================

  /// Logout current user
  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      print('Logout error: $e');
      // Continue logout even if backend call fails
    } finally {
      _currentUser = null;
      _clearError();
      _setState(AuthState.unauthenticated);
    }
  }

  // ==================== Helper Methods ====================

  /// Set authentication state
  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Set error message and state
  void _setError(String message) {
    _errorMessage = message;
    _state = AuthState.error;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _clearError();
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }
}
