import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/legal_texts.dart';
import '../utils/text_styles.dart';
import '../widgets/app_logo.dart';
import '../widgets/info_dialog.dart';
import '../widgets/input_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/social_button.dart';
import '../widgets/tab_button.dart';
import 'forgot_password.dart';
import 'main_shell.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLogin = true; // true = Login, false = Sign Up
  bool _isLoading = false; // email sign in / sign up in progress
  bool _isGoogleLoading = false; // Google sign in in progress

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _handleSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLogin) {
        // main.dart's auth stream routes to the verify screen or homepage.
        final credential =
            await AuthService().signInWithEmail(email, password);
        final user = credential.user;
        if (user != null && user.emailVerified) {
          UserService()
              .markEmailVerified(
                user.uid,
                email: user.email ?? email,
                displayName: user.displayName ?? '',
              )
              .ignore();
        }
      } else {
        final credential = await AuthService().signUpWithEmail(
          email,
          password,
          displayName: _nameController.text.trim(),
        );
        final uid = credential.user?.uid;
        // emailVerified = 0 until the user confirms via the emailed link.
        if (uid != null) {
          UserService()
              .createUserDocument(
                uid,
                email: email,
                displayName: _nameController.text.trim(),
                emailVerified: 0,
              )
              .then((_) => debugPrint('users/$uid created (emailVerified=0)'))
              .catchError(
                (Object e) => debugPrint('create users/$uid FAILED: $e'),
              );
        }
        // main.dart's auth stream shows the verify-email screen next.
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e is String ? e : 'Something went wrong. Please try again'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showUnderConstruction(String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('$feature is under construction')),
      );
  }

  void _handleSocialLogin(String provider) {
    // Google / Phone auth temporarily disabled. To re-enable, call
    // _handleGoogleSignIn() or push PhoneAuthScreen() here.
    _showUnderConstruction('$provider sign-in');
  }

  // ignore: unused_element
  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isGoogleLoading = true;
    });

    try {
      final credential = await AuthService().signInWithGoogle();
      final user = credential.user;
      final isNewUser = credential.additionalUserInfo?.isNewUser ?? false;
      // Navigate immediately — Firestore write in background to avoid race
      // where authStateChanges fires before navigation completes.
      if (isNewUser && user != null) {
        UserService()
            .createUserDocument(
              user.uid,
              email: user.email ?? '',
              displayName: user.displayName ?? '',
            )
            .ignore();
      }
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainShell(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e is String ? e : 'Something went wrong. Please try again'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  // ignore: unused_element
  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    final screenContext = context;
    bool isSending = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF2A2A2E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text(
                'Reset Password',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enter your email address and we\'ll send you a link to reset your password.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'name@example.com',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      filled: true,
                      fillColor: AppColors.inputBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: TextButton.styleFrom(foregroundColor: Colors.grey[400]),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: isSending
                      ? null
                      : () async {
                          final email = emailController.text.trim();
                          setDialogState(() => isSending = true);
                          try {
                            await AuthService().sendPasswordResetEmail(email);
                            if (!dialogContext.mounted) return;
                            Navigator.pop(dialogContext);
                            if (!screenContext.mounted) return;
                            ScaffoldMessenger.of(screenContext).showSnackBar(
                              const SnackBar(content: Text('Password reset email sent')),
                            );
                          } catch (e) {
                            setDialogState(() => isSending = false);
                            if (!dialogContext.mounted) return;
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Text(e is String ? e : 'Failed to send reset email'),
                              ),
                            );
                          }
                        },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: isSending ? AppColors.primary.withValues(alpha: 0.5) : AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: isSending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Send', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/kimmich.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Dark overlay to reduce transparency
          Container(
            color: AppColors.bgOverlay,
          ),
          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 190),
                  // Logo and branding
                  const AppLogo(),
                  const SizedBox(height: 40),
                  // Login/Sign Up tabs
                  Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          text: 'Login',
                          isActive: _isLogin,
                          onPressed: () {
                            setState(() {
                              _isLogin = true;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SecondaryButton(
                          text: 'Sign Up',
                          isActive: !_isLogin,
                          onPressed: () {
                            setState(() {
                              _isLogin = false;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Full Name field (only for Sign Up)
                  if (!_isLogin) ...[
                    CustomTextField(
                      label: 'Full Name',
                      hint: 'John Doe',
                      prefixIcon: Icons.person_outline,
                      controller: _nameController,
                    ),
                    const SizedBox(height: 20),
                  ],
                  // Email field
                  CustomTextField(
                    label: 'Email Address',
                    hint: 'name@example.com',
                    prefixIcon: Icons.email_outlined,
                    controller: _emailController,
                  ),
                  const SizedBox(height: 20),
                  // Password field
                  CustomTextField(
                    label: 'Password',
                    hint: '••••••••',
                    prefixIcon: Icons.lock_outline,
                    controller: _passwordController,
                    isPassword: true,
                    obscureText: _obscurePassword,
                    onTogglePassword: _togglePasswordVisibility,
                  ),
                  // Forgot password (only for Login)
                  if (_isLogin) ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordScreen(),
                          ),
                        ),
                        child: Text(
                          AppConstants.forgotPassword,
                          style: AppTextStyles.link,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  // Sign In/Create Account button
                  PrimaryButton(
                    text: _isLogin ? 'Sign In' : 'Create Account',
                    onPressed: _handleSignIn,
                    isLoading: _isLoading,
                    disabled: _isGoogleLoading,
                  ),
                  const SizedBox(height: 32),
                  // OR divider
                  Text(
                    _isLogin ? 'OR CONTINUE WITH' : 'OR SIGN UP WITH',
                    style: AppTextStyles.inputLabel,
                  ),
                  const SizedBox(height: 24),
                  // Social login buttons
                  Row(
                    children: [
                      Expanded(
                        child: SocialButton(
                          text: 'Google',
                          svgPath: 'assets/images/googleLogo.svg',
                          onPressed: () => _handleSocialLogin('Google'),
                          isLoading: _isGoogleLoading,
                          disabled: _isLoading,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SocialButton(
                          text: 'Phone',
                          icon: Icons.phone_outlined,
                          isDark: true,
                          onPressed: () => _handleSocialLogin('Phone'),
                          disabled: _isLoading || _isGoogleLoading,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Terms and Privacy
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          InfoDialog.show(
                            context,
                            AppConstants.termsOfService,
                            LegalTexts.termsOfService,
                          );
                        },
                        child: Text(
                          AppConstants.termsOfService,
                          style: AppTextStyles.footer,
                        ),
                      ),
                      Text('  •  ', style: AppTextStyles.footer),
                      TextButton(
                        onPressed: () {
                          InfoDialog.show(
                            context,
                            AppConstants.privacyPolicy,
                            LegalTexts.privacyPolicy,
                          );
                        },
                        child: Text(
                          AppConstants.privacyPolicy,
                          style: AppTextStyles.footer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
