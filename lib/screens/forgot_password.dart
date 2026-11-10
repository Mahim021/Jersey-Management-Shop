import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/colors.dart';
import '../widgets/input_field.dart';
import '../widgets/primary_button.dart';

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

String _errorText(Object e) =>
    e is String ? e : 'Something went wrong. Please try again';

Widget _header(String title, String subtitle) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textWhite,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(color: AppColors.textGrey, fontSize: 15),
        ),
        const SizedBox(height: 32),
      ],
    );

/// Step 1: ask for the account email and send the reset email.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendLink() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showMessage(context, 'Please enter your email address');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await AuthService().sendPasswordResetEmail(email);
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'If an account exists for $email, a password reset link has been sent. '
              'Open it to set a new password, then sign in.',
            ),
            duration: const Duration(seconds: 6),
          ),
        );
    } catch (e) {
      if (mounted) _showMessage(context, _errorText(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        foregroundColor: AppColors.textWhite,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(
                'Forgot Password',
                'Enter your email and we\'ll send you a link to reset your password.',
              ),
              CustomTextField(
                label: 'Email Address',
                hint: 'name@example.com',
                prefixIcon: Icons.email_outlined,
                controller: _emailController,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Send Reset Link',
                onPressed: _sendLink,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
