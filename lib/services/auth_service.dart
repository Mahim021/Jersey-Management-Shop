import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'user_service.dart';

/// Singleton wrapper around FirebaseAuth that converts Firebase exceptions
/// into human-readable error messages for the UI.
class AuthService {
  AuthService._internal();
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Like [authStateChanges] but also emits when the user is reloaded
  /// (e.g. after emailVerified changes).
  Stream<User?> get userChanges =>
      _firebaseAuth.userChanges().where((_) => !_checkingLogin);

  // While true, auth events are hidden from the UI so a login attempt on an
  // unverified account never flashes the verify screen before being rejected.
  bool _checkingLogin = false;

  /// True when the user signed up with email/password and hasn't yet
  /// confirmed their email address.
  bool needsEmailVerification(User user) =>
      !user.emailVerified &&
      user.providerData.any((p) => p.providerId == 'password');

  /// How long an unverified sign-up is kept before it is deleted.
  static const unverifiedAccountLifetime = Duration(hours: 24);

  /// True if [user] never verified their email within
  /// [unverifiedAccountLifetime] of creating the account.
  bool isUnverifiedAccountExpired(User user) =>
      needsEmailVerification(user) &&
      _timeUntilExpiry(user) <= Duration.zero;

  Duration _timeUntilExpiry(User user) {
    final created = user.metadata.creationTime;
    if (created == null) return unverifiedAccountLifetime;
    return created.add(unverifiedAccountLifetime).difference(DateTime.now());
  }

  String _formatDuration(Duration d) {
    if (d.inHours >= 1) return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    if (d.inMinutes >= 1) return '${d.inMinutes}m ${d.inSeconds.remainder(60)}s';
    return '${d.inSeconds < 1 ? 1 : d.inSeconds}s';
  }

  Future<void> sendEmailVerification() async {
    try {
      await _firebaseAuth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw switch (e.code) {
        'too-many-requests' => 'Too many requests. Try again in a few minutes',
        'network-request-failed' => 'No internet connection. Please check your network',
        _ => 'Could not send verification email. Please try again',
      };
    }
  }

  /// Reloads the current user and returns whether their email is verified.
  Future<bool> refreshEmailVerified() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return false;
    await user.reload();
    return _firebaseAuth.currentUser?.emailVerified ?? false;
  }

  String? get currentUserId => _firebaseAuth.currentUser?.uid;

  User? get currentUser => _firebaseAuth.currentUser;

  static const _alreadyRegistered =
      'This email is already registered, or you already tried signing up with '
      'it and have not verified it. Check your inbox for the verification '
      'link, or try again after 24 hours';

  Future<UserCredential> signInWithEmail(String email, String password) async {
    _checkingLogin = true;
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      debugPrint(
        'signInWithEmail ok: emailVerified=${user?.emailVerified}, '
        'providers=${user?.providerData.map((p) => p.providerId).toList()}',
      );
      if (user != null && needsEmailVerification(user)) {
        final remaining = _timeUntilExpiry(user);
        if (remaining <= Duration.zero) {
          // Verification window is over: remove the stale account.
          await deleteCurrentAccount();
          throw 'You left your email unverified, so that account was removed. '
              'You can now sign up again with this email';
        }
        await signOut();
        throw 'You left your email unverified. Check your inbox for the '
            'verification link, or try again after '
            '${_formatDuration(remaining)} to recreate an account with this email';
      }
      _checkingLogin = false;
      // The sign-in event was hidden; reloading re-emits it so the app
      // moves on to the homepage.
      await user?.reload();
      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('signInWithEmail failed: ${e.code} — ${e.message}');
      throw switch (e.code) {
        'user-not-found' => 'No account found with this email',
        // Firebase's email enumeration protection unifies "no such account"
        // and "wrong password" into invalid-credential so the two cases
        // can't be told apart from the client.
        'wrong-password' || 'invalid-credential' =>
          'Wrong email or password',
        'invalid-email' => 'Invalid email address',
        'user-disabled' => 'This account has been disabled',
        'too-many-requests' => 'Too many attempts. Try again later',
        'network-request-failed' => 'No internet connection. Please check your network',
        'operation-not-allowed' =>
          'Email/password sign-in is not enabled for this project',
        _ => 'Sign in failed. Please try again',
      };
    } finally {
      _checkingLogin = false;
    }
  }

  Future<UserCredential> signUpWithEmail(
    String email,
    String password, {
    String displayName = '',
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // With Firebase's email enumeration protection enabled, signing up
      // with an email/password that matches an existing account succeeds
      // silently instead of throwing 'email-already-in-use', to avoid
      // leaking whether an email is registered. isNewUser is the only
      // reliable signal that this actually created a fresh account.
      final isNewUser = credential.additionalUserInfo?.isNewUser ?? true;
      if (!isNewUser) {
        await _firebaseAuth.signOut();
        throw _alreadyRegistered;
      }
      // Keep the name on the auth user; the Firestore profile is only
      // created after the email is verified.
      await credential.user?.updateDisplayName(displayName);
      // Best effort: the verify screen has a Resend button if this fails.
      try {
        await credential.user?.sendEmailVerification();
      } catch (e) {
        debugPrint('sendEmailVerification failed: $e');
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('signUpWithEmail failed: ${e.code} — ${e.message}');
      throw switch (e.code) {
        'email-already-in-use' => _alreadyRegistered,
        'weak-password' => 'Password must be at least 6 characters',
        'invalid-email' => 'Invalid email address',
        'network-request-failed' => 'No internet connection. Please check your network',
        'operation-not-allowed' =>
          'Email/password sign-in is not enabled for this project',
        _ => 'Sign up failed. Please try again',
      };
    }
  }

  /// Deletes the current account (used to discard a sign-up whose email was
  /// never verified). Falls back to a plain sign out if deletion fails.
  Future<void> deleteCurrentAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        try {
          await UserService()
              .deleteUserDocument(user.uid)
              .timeout(const Duration(seconds: 5));
        } catch (e) {
          debugPrint('deleteUserDocument failed: $e');
        }
        await user.delete();
      }
    } catch (e) {
      debugPrint('deleteCurrentAccount failed: $e');
    }
    await signOut();
  }

  Future<void> signOut() async {
    try {
      await GoogleSignIn().signOut();
    } catch (e) {
      debugPrint('Google signOut failed: $e');
    }
    await _firebaseAuth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw switch (e.code) {
        'user-not-found' => 'No account found with this email',
        'invalid-email' => 'Invalid email address',
        _ => 'Failed to send reset email',
      };
    }
  }

  /// Checks the reset code from the password-reset email. Returns the
  /// account's email if the code is valid.
  Future<String> verifyPasswordResetCode(String code) async {
    try {
      return await _firebaseAuth.verifyPasswordResetCode(code);
    } on FirebaseAuthException catch (e) {
      throw switch (e.code) {
        'expired-action-code' => 'This code has expired. Request a new one',
        'invalid-action-code' => 'Invalid code. Please check and try again',
        'network-request-failed' => 'No internet connection. Please check your network',
        _ => 'Could not verify the code. Please try again',
      };
    }
  }

  /// Sets a new password using the code from the password-reset email.
  Future<void> confirmPasswordReset(String code, String newPassword) async {
    try {
      await _firebaseAuth.confirmPasswordReset(
        code: code,
        newPassword: newPassword,
      );
    } on FirebaseAuthException catch (e) {
      throw switch (e.code) {
        'expired-action-code' => 'This code has expired. Request a new one',
        'invalid-action-code' => 'Invalid code. Please check and try again',
        'weak-password' => 'Password must be at least 6 characters',
        'network-request-failed' => 'No internet connection. Please check your network',
        _ => 'Could not reset password. Please try again',
      };
    }
  }

  /// Signs in with Google using the Intent-based flow (google_sign_in 6.x).
  /// Returns the signed-in credential.
  /// [UserCredential.additionalUserInfo?.isNewUser] can be used to route
  /// first-time Google sign-ups through the onboarding flow.
  Future<UserCredential> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn(
        serverClientId:
            '715028127856-qqodffufldam515i27ns845t9plp4hg3.apps.googleusercontent.com',
      ).signIn();
      if (googleUser == null) throw 'Sign-in cancelled';

      final googleAuth = await googleUser.authentication;
      debugPrint(
        'Google auth — idToken: ${googleAuth.idToken != null ? "present" : "null"}, '
        'accessToken: ${googleAuth.accessToken != null ? "present" : "null"}',
      );

      if (googleAuth.idToken == null) {
        throw 'Google sign-in failed: no ID token returned. '
            'Ensure Google is enabled in Firebase Authentication.';
      }

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      return await _firebaseAuth.signInWithCredential(credential).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw 'Connection timed out. Please try again.',
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('signInWithGoogle Firebase error: ${e.code} — ${e.message}');
      throw switch (e.code) {
        'account-exists-with-different-credential' =>
          'An account already exists with a different sign-in method',
        'operation-not-allowed' =>
          'Google sign-in is not enabled. Enable it in Firebase Authentication.',
        'network-request-failed' => 'No internet connection. Please check your network',
        _ => 'Google sign-in failed. Please try again',
      };
    } catch (e) {
      if (e is String) rethrow;
      debugPrint('signInWithGoogle unknown error: $e');
      throw 'Google sign-in failed. Please try again';
    }
  }
}
