import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/api_error.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../utils/constants.dart';
import '../utils/logger.dart';

/// Authentication state enum
enum AuthState {
  initial, // App just started, checking auth status
  loading, // Processing auth request
  authenticated, // User is logged in
  unauthenticated, // User is not logged in
  error, // Auth error occurred
}

/// Authentication provider using Provider pattern
/// Manages authentication state and user data
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  // State
  AuthState _state = AuthState.initial;
  User? _currentUser;
  String? _errorMessage;


  // Getters
  AuthState get state => _state;
  User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == AuthState.loading;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isUnauthenticated => _state == AuthState.unauthenticated;


  /// Check if user has complete profile data
  bool get isUserComplete {
    if (_currentUser == null) return false;

    // Check if user has a valid role (ui names and backend names)
    final validRoles = [
      'IbuHamil',
      'IbuMenyusui',
      'Batita',
      'AnakBatita',
      'IBU_HAMIL',
      'IBU_MENYUSUI',
      'ANAK_BATITA',
    ];
    final role = _currentUser!.role?.trim() ?? '';
    return role.isNotEmpty && validRoles.contains(role);
  }



  /// Update current user role
  Future<void> updateUserRole(String role, {String? token}) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(role: role);
      // Save updated user to storage
      await _authService.updateUser(_currentUser!);

      // Save new token if provided (role might have changed in backend)
      if (token != null) {
        await _authService.saveToken(token);
      }

      notifyListeners();
    }
  }

  /// Update current user name
  Future<void> updateUserName(String name) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(name: name);
      // Save updated user to storage
      await _authService.updateUser(_currentUser!);
      notifyListeners();
    }
  }

  /// Update current user avatar
  Future<void> updateUserAvatar(String avatar) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(avatar: avatar);
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
      // Sync Google session state in background
      _authService.signInSilently();
      
      // Step 1: Check if user has stored token and user data
      final hasToken = await _authService.isAuthenticated();
      final storedUser = await _authService.getCurrentUser();

      if (hasToken && storedUser != null) {
        // OPTIMISTIC AUTH: If we have a token and user data locally, 
        // assume authenticated immediately so user can enter the app.
        _currentUser = storedUser;
        _setState(AuthState.authenticated);
        
        // Step 2: Validate token and refresh data in background
        // We do this without blocking the UI
        unawaited(_refreshUser(isInitialCheck: true));
        return;
      }

      // No valid session found locally
      _setState(AuthState.unauthenticated);
    } catch (e) {
      AppLogger.e('Error checking auth status', e);
      _setState(AuthState.unauthenticated);
    }
  }

  /// Refresh user data from backend
  Future<void> _refreshUser({bool isInitialCheck = false}) async {
    try {
      // 1. Fetch current user profile data
      final userProfile = await _userService.getUserProfile();

      if (_currentUser != null) {
        // Update user data with fresh profile info
        final updatedUser = _currentUser!.copyWith(
          name: userProfile['name'] as String?,
          avatar: userProfile['avatar'] as String?,
          role: userProfile['role'] as String?,
        );

        // Only update if there are changes
        if (updatedUser != _currentUser) {
          _currentUser = updatedUser;
          await _authService.updateUser(_currentUser!);
          notifyListeners();
        }
      }

      // 2. Fetch current preferences (for role validation)
      final preference = await _userService.getPreference();

      if (preference != null && _currentUser != null) {
        if (_currentUser!.role != preference.role) {
          _currentUser = _currentUser!.copyWith(role: preference.role);
          await _authService.updateUser(_currentUser!);
          notifyListeners();
        }
      }
    } on ApiError catch (e) {
      // CRITICAL: Only logout if it's strictly an AUTH error
      if (e.isAuthError) {
        AppLogger.w('Authentication error during user refresh: ${e.code}');
        await logout();
        return;
      }
      
      // If it's a connection error or server down, we stay authenticated
      // but log the warning.
      if (e.isConnectionError) {
        AppLogger.w('Network/Server error during background refresh. Staying offline.');
      } else {
        AppLogger.e('Error refreshing user data: ${e.code}', e);
      }
    } catch (e) {
      AppLogger.e('Unexpected error refreshing user data', e);
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
      // Handle auth errors specifically
      if (_isAuthError(e)) {
        await logout();
        _setError(ApiConstants.getErrorMessage(e.code));
        return false;
      }
      _setError(ApiConstants.getErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError(ApiConstants.getErrorMessage('SERVER_ERROR'));
      return false;
    }
  }

  // ==================== Login ====================

  /// Login user with email and password
  Future<bool> login({required String email, required String password}) async {
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
      // Handle auth errors specifically
      if (_isAuthError(e)) {
        await logout();
        _setError(ApiConstants.getErrorMessage(e.code));
        return false;
      }
      _setError(ApiConstants.getErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError(ApiConstants.getErrorMessage('SERVER_ERROR'));
      return false;
    }
  }

  // ==================== Google Sign-In ====================
  
  /// Sign in with Google account
  Future<bool> signInWithGoogle() async {
    _setState(AuthState.loading);
    _clearError();
    // No need for separate _isGoogleSignInInProgress flag anymore
    notifyListeners();

    try {
      final authResponse = await _authService.signInWithGoogle();

      _currentUser = authResponse.user;
      // Set authenticated immediately - Router will handle navigation
      _setState(AuthState.authenticated); 
      return true;
    } on ApiError catch (e) {
      // Handle auth errors specifically
      if (_isAuthError(e)) {
        await logout();
        _setError(ApiConstants.getErrorMessage(e.code));
        return false;
      }
      // Don't show error if user cancelled sign-in
      if (e.code != 'GOOGLE_SIGNIN_CANCELLED') {
        _setError(ApiConstants.getErrorMessage(e.code));
      } else {
        _setState(AuthState.unauthenticated);
      }
      return false;
    } catch (e) {
       _setError(ApiConstants.getErrorMessage('SERVER_ERROR'));
      return false;
    }
  }

  // ==================== Logout ====================

  /// Logout current user
  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      AppLogger.e('Logout error', e);
      // Continue logout even if backend call fails
    } finally {
      _currentUser = null;
      _clearError();
      _setState(AuthState.unauthenticated);
    }
  }

  // ==================== Helper Methods ====================

  /// Check if error is authentication-related
  bool _isAuthError(ApiError error) {
    return error.isAuthError;
  }

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
