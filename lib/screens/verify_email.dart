import 'dart:async';

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../utils/colors.dart';
import '../widgets/primary_button.dart';

/// Shown to signed-in email/password users until they confirm their email.
/// main.dart swaps this for the homepage once the user's email is verified.
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  static const _resendCooldown = 60;

  bool _isChecking = false;
  bool _isResending = false;
  int _secondsLeft = _resendCooldown; // a mail was just sent at sign-up
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCooldown();
    _deleteIfExpired();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Deletes the account if the verification window has passed. The auth
  /// stream then sends the user back to the login page.
  Future<bool> _deleteIfExpired() async {
    final user = AuthService().currentUser;
    if (user == null || !AuthService().isUnverifiedAccountExpired(user)) {
      return false;
    }
    debugPrint(
      'Unverified account expired (created '
      '${user.metadata.creationTime}, now ${DateTime.now()}) - deleting',
    );
    await AuthService().deleteCurrentAccount();
    return true;
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendCooldown);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) t.cancel();
    });
  }

  void _show(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _checkVerified() async {
    setState(() => _isChecking = true);
    try {
      if (await _deleteIfExpired()) return;
      final verified = await AuthService().refreshEmailVerified();
      final user = AuthService().currentUser;
      if (verified && user != null) {
        // Email confirmed: set emailVerified = 1 in Firestore.
        UserService()
            .markEmailVerified(
              user.uid,
              email: user.email ?? '',
              displayName: user.displayName ?? '',
            )
            .ignore();
      }
      // On success the auth stream in main.dart swaps this screen for the
      // homepage, so there is nothing to navigate to here.
      if (!verified && mounted) {
        _show('Email not verified yet. Open the link in your email first');
      }
    } catch (_) {
      if (mounted) _show('Could not check status. Please try again');
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  Future<void> _resend() async {
    setState(() => _isResending = true);
    try {
      if (await _deleteIfExpired()) return;
      await AuthService().sendEmailVerification();
      if (!mounted) return;
      _show('Verification email sent');
      _startCooldown();
    } catch (e) {
      if (mounted) _show(e is String ? e : 'Could not send email');
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = AuthService().currentUser?.email ?? 'your email';
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Column(
            children: [
              const Icon(Icons.mark_email_unread_outlined,
                  size: 72, color: AppColors.primary),
              const SizedBox(height: 24),
              const Text(
                'Verify your email',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'We sent a verification link to $email. Open it, then come back and tap the button below.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textGrey, fontSize: 15),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: "I've verified my email",
                onPressed: _checkVerified,
                isLoading: _isChecking,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed:
                    (_secondsLeft > 0 || _isResending) ? null : _resend,
                child: Text(
                  _secondsLeft > 0
                      ? 'Resend email in ${_secondsLeft}s'
                      : 'Resend email',
                ),
              ),
              TextButton(
                onPressed: () => AuthService().deleteCurrentAccount(),
                child: const Text(
                  'Use a different account',
                  style: TextStyle(color: AppColors.textGrey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
