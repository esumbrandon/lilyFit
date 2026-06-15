import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service class for handling Apple Sign-In authentication
///
/// This service provides a clean interface for Apple OAuth authentication
/// and integrates with Supabase for backend user management.
///
/// Note: Apple Sign-In is only available on iOS devices.
class AppleSignInService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Sign in with Apple ID
  ///
  /// Returns an [AuthResponse] from Supabase containing user and session data.
  /// Throws an [Exception] if sign-in fails, is cancelled, or attempted on non-iOS platform.
  Future<AuthResponse> signIn() async {
    // Platform check
    if (!Platform.isIOS) {
      throw Exception('Sign in with Apple is only available on iOS devices');
    }

    try {
      // Generate secure nonce for additional security
      final rawNonce = _generateNonce();
      final hashedNonce = _hashNonce(rawNonce);

      // Request Apple ID credential
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      // Validate ID token
      final idToken = credential.identityToken;
      if (idToken == null) {
        throw Exception('No ID Token received from Apple sign-in');
      }

      // Sign in to Supabase with Apple credentials
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );

      if (response.user == null) {
        throw Exception('Apple sign-in failed: No user returned from Supabase');
      }

      // Update user metadata with name if provided
      // Note: Apple only provides name on first sign-in
      await _updateUserNameIfAvailable(credential);

      _logDebug('Apple sign-in successful for user: ${response.user!.email}');
      return response;
    } on SignInWithAppleAuthorizationException catch (e) {
      _logError('Apple sign-in authorization exception', e);
      throw _handleAppleAuthException(e);
    } on AuthException catch (e) {
      _logError('Apple sign-in auth exception', e);
      throw Exception('Apple sign-in authentication error: ${e.message}');
    } catch (e) {
      _logError('Apple sign-in general exception', e);
      throw Exception('Apple sign-in error: ${e.toString()}');
    }
  }

  /// Update user metadata with name from Apple credential if available
  Future<void> _updateUserNameIfAvailable(
    AuthorizationCredentialAppleID credential,
  ) async {
    try {
      // Apple only provides name on first sign-in, so we store it immediately
      if (credential.givenName != null || credential.familyName != null) {
        final fullName = _buildFullName(
          givenName: credential.givenName,
          familyName: credential.familyName,
        );

        if (fullName.isNotEmpty) {
          await _supabase.auth.updateUser(
            UserAttributes(data: {'name': fullName}),
          );
          _logDebug('Updated user name: $fullName');
        }
      }
    } catch (e) {
      // Don't throw - name update is not critical
      _logError('Failed to update user name', e);
    }
  }

  /// Build full name from given name and family name
  String _buildFullName({String? givenName, String? familyName}) {
    final parts = <String>[];

    if (givenName != null && givenName.isNotEmpty) {
      parts.add(givenName);
    }

    if (familyName != null && familyName.isNotEmpty) {
      parts.add(familyName);
    }

    return parts.join(' ').trim();
  }

  /// Generate a cryptographically secure random nonce
  ///
  /// The nonce is used to prevent replay attacks.
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();

    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  /// Hash the nonce using SHA-256
  String _hashNonce(String nonce) {
    return sha256.convert(utf8.encode(nonce)).toString();
  }

  /// Handle Apple Sign-In authorization exceptions
  Exception _handleAppleAuthException(SignInWithAppleAuthorizationException e) {
    switch (e.code) {
      case AuthorizationErrorCode.canceled:
        return Exception('Apple sign-in was cancelled by user');

      case AuthorizationErrorCode.failed:
        return Exception(
          'Apple sign-in failed. Please try again or use another sign-in method.',
        );

      case AuthorizationErrorCode.invalidResponse:
        return Exception(
          'Invalid response from Apple sign-in. Please try again.',
        );

      case AuthorizationErrorCode.notHandled:
        return Exception(
          'Apple sign-in request was not handled. Please try again.',
        );

      case AuthorizationErrorCode.unknown:
        return Exception(
          'An unknown error occurred during Apple sign-in: ${e.message}',
        );

      default:
        return Exception('Apple sign-in error: ${e.message}');
    }
  }

  /// Check if Apple Sign-In is available on the current device
  static Future<bool> isAvailable() async {
    if (!Platform.isIOS) {
      return false;
    }

    try {
      return await SignInWithApple.isAvailable();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AppleSignInService] Error checking availability: $e');
      }
      return false;
    }
  }

  /// Get credential state for a given user identifier
  ///
  /// This can be used to check if the user's Apple ID credential is still valid.
  Future<CredentialState> getCredentialState(String userIdentifier) async {
    if (!Platform.isIOS) {
      throw Exception('This method is only available on iOS');
    }

    return await SignInWithApple.getCredentialState(userIdentifier);
  }

  /// Log debug messages (only in debug mode)
  void _logDebug(String message) {
    if (kDebugMode) {
      debugPrint('[AppleSignInService] $message');
    }
  }

  /// Log error messages
  void _logError(String message, Object error) {
    if (kDebugMode) {
      debugPrint('[AppleSignInService] ERROR: $message - $error');
    }
  }
}
