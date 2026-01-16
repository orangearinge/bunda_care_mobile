import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/auth_response.dart';
import '../models/api_error.dart';
import '../models/user.dart';
import '../utils/constants.dart';
import '../utils/error_handler.dart';
import '../utils/logger.dart';
import 'api_service.dart';
import 'storage_service.dart';

/// Authentication service
/// Handles all authentication-related API calls
class AuthService {
  final ApiService _api = ApiService();
  final StorageService _storage = StorageService();
  late final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    clientId: kIsWeb ? dotenv.env['GOOGLE_CLIENT_ID'] : null,
    serverClientId: !kIsWeb ? dotenv.env['GOOGLE_CLIENT_ID'] : null,
  );

  // ==================== Email/Password Auth ====================

  /// Register new user with email and password
  /// POST /api/auth/register
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _api.post(
        ApiConstants.register,
        data: {
          'name': name.trim(),
          'email': email.trim().toLowerCase(),
          'password': password,
        },
      );

      final data = _api.unwrap(response);
      final authResponse = AuthResponse.fromJson(data);

      // Save token and user data
      await _storage.saveToken(authResponse.token);
      await _storage.saveUser(authResponse.user);

      return authResponse;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// Login user with email and password
  /// POST /api/auth/login
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _api.post(
        ApiConstants.login,
        data: {'email': email.trim().toLowerCase(), 'password': password},
      );

      final data = _api.unwrap(response);
      final authResponse = AuthResponse.fromJson(data);

      // Save token and user data
      await _storage.saveToken(authResponse.token);
      await _storage.saveUser(authResponse.user);

      return authResponse;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  // ==================== Google Sign-In ====================

  /// Sign in with Google
  /// This method handles the entire Google OAuth flow:
  /// 1. Prompt user to select Google account
  /// 2. Get ID token from Google
  /// 3. Send ID token to backend for verification
  /// 4. Receive JWT token from backend
  Future<AuthResponse> signInWithGoogle() async {
    try {
      // Step 1: Sign in with Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        throw ApiError(
          code: 'GOOGLE_AUTH_CANCELLED',
          message: ApiConstants.getErrorMessage('GOOGLE_AUTH_CANCELLED'),
        );
      }

      // Step 2: Get authentication token
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw ApiError(
          code: 'INVALID_TOKEN',
          message: ApiConstants.getErrorMessage('INVALID_TOKEN'),
        );
      }

      // Step 3: Send token to backend
      final response = await _api.post(
        ApiConstants.googleAuth,
        data: {'token': idToken},
      );

      final data = _api.unwrap(response);
      final authResponse = AuthResponse.fromJson(data);

      // Save token and user data
      await _storage.saveToken(authResponse.token);
      await _storage.saveUser(authResponse.user);

      return authResponse;
    } catch (e) {
      // Sign out from Google on error
      await _googleSignIn.signOut();

      AppLogger.e('Google sign-in error', e);
      throw ErrorHandler.handle(e);
    }
  }

  // ==================== Logout ====================

  /// Logout user
  /// Clears local storage and calls backend logout endpoint
  Future<void> logout() async {
    try {
      // Call backend logout (optional - JWT is stateless)
      try {
        await _api.post(ApiConstants.logout);
      } catch (e) {
        // Ignore backend logout errors - we still want to logout locally
        AppLogger.w('Backend logout failed: $e');
      }

      // Sign out from Google if user signed in with Google
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      // Clear all local storage
      await _storage.clearAll();
    } catch (e) {
      throw ApiError(
        code: 'LOGOUT_FAILED',
        message: ApiConstants.getErrorMessage('LOGOUT_FAILED'),
      );
    }
  }

  // ==================== Session Management ====================

  /// Check if user is authenticated (has valid token)
  Future<bool> isAuthenticated() async {
    return await _storage.hasToken();
  }

  /// Get current stored token
  Future<String?> getToken() async {
    return await _storage.getToken();
  }

  /// Get current stored user
  Future<dynamic> getCurrentUser() async {
    return await _storage.getUser();
  }

  /// Update and save user data
  Future<void> updateUser(User user) async {
    await _storage.saveUser(user);
  }

  /// Save authentication token
  Future<void> saveToken(String token) async {
    await _storage.saveToken(token);
  }
}
