import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service class for handling Google Sign-In authentication
///
/// This service provides a clean interface for Google OAuth authentication
/// and integrates with Supabase for backend user management.
class GoogleSignInService {
  // Google OAuth Client IDs
  static const String _webClientId =
      '570529075069-2o04k1seuql019nimobbqmcc1unrhcvh.apps.googleusercontent.com';
  static const String _iosClientId =
      '570529075069-rh3r7m6vlf0nbc6nkmep9sulv53djkt8.apps.googleusercontent.com';

  final SupabaseClient _supabase = Supabase.instance.client;
  late final GoogleSignIn _googleSignIn;

  GoogleSignInService() {
    _googleSignIn = GoogleSignIn(
      clientId: Platform.isIOS ? _iosClientId : null,
      serverClientId: _webClientId,
      scopes: ['email', 'profile', 'openid'],
    );
  }

  /// Sign in with Google account
  ///
  /// Returns an [AuthResponse] from Supabase containing user and session data.
  /// Throws an [Exception] if sign-in fails or is cancelled.
  Future<AuthResponse> signIn() async {
    try {
      await _googleSignIn.signOut();

      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google sign-in was cancelled by user');
      }

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw Exception('No Access Token found from Google');
      }
      if (idToken == null) {
        throw Exception('No ID Token found from Google');
      }

      // Sign in to Supabase with Google credentials
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user == null) {
        throw Exception(
          'Google sign-in failed: No user returned from Supabase',
        );
      }

      _logDebug('Google sign-in successful for user: ${response.user!.email}');
      return response;
    } on PlatformException catch (e) {
      _logError('Google sign-in platform exception', e);
      throw _handlePlatformException(e);
    } on AuthException catch (e) {
      _logError('Google sign-in auth exception', e);
      throw Exception('Google sign-in authentication error: ${e.message}');
    } catch (e) {
      _logError('Google sign-in general exception', e);
      throw Exception('Google sign-in error: ${e.toString()}');
    }
  }

  /// Sign out from Google account
  ///
  /// This will clear the Google Sign-In session locally.
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      _logDebug('Google sign-out successful');
    } catch (e) {
      // Silently fail - sign out is best effort
      _logError('Google sign out error', e);
    }
  }

  /// Check if user is currently signed in with Google
  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  /// Get the currently signed-in Google user
  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  /// Handle platform-specific exceptions from Google Sign-In
  Exception _handlePlatformException(PlatformException e) {
    switch (e.code) {
      case 'sign_in_failed':
        return Exception(
          'Google Sign-In configuration error. Please ensure:\n'
          '1. SHA-1 certificates are added to Google Cloud Console\n'
          '2. Package name matches: app.cypherwave.lilyfit\n'
          '3. OAuth client IDs are correctly configured\n'
          '4. Wait 5-10 minutes after adding certificates\n'
          'Error details: ${e.message}',
        );

      case 'network_error':
        return Exception(
          'Network error during Google Sign-In. '
          'Please check your internet connection and try again.',
        );

      case 'sign_in_canceled':
        return Exception('Google sign-in was cancelled');

      case 'sign_in_required':
        return Exception('Google sign-in is required to continue');

      default:
        return Exception('Google sign-in error: ${e.message ?? e.code}');
    }
  }

  /// Disconnect the Google account
  ///
  /// This revokes access and signs out the user completely.
  Future<void> disconnect() async {
    try {
      await _googleSignIn.disconnect();
      _logDebug('Google disconnect successful');
    } catch (e) {
      _logError('Google disconnect error', e);
    }
  }

  /// Log debug messages (only in debug mode)
  void _logDebug(String message) {
    if (kDebugMode) {
      debugPrint('[GoogleSignInService] $message');
    }
  }

  /// Log error messages
  void _logError(String message, Object error) {
    if (kDebugMode) {
      debugPrint('[GoogleSignInService] ERROR: $message - $error');
    }
  }
}
