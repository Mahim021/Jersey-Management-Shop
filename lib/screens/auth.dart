import 'package:flutter/material.dart';
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
import 'phone_auth.dart';

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
  bool _isLoading = false;

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

  void _handleSignIn() {
    setState(() {
      _isLoading = true;
    });
    
    // TODO: Implement actual sign in/up logic
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _handleSocialLogin(String provider) {
    if (provider == 'Phone') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PhoneAuthScreen()),
      );
    } else {
      // TODO: Implement other social logins
      debugPrint('Login with $provider');
    }
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
                        onPressed: () {
                          // TODO: Implement forgot password
                        },
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
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SocialButton(
                          text: 'Phone',
                          icon: Icons.phone_outlined,
                          isDark: true,
                          onPressed: () => _handleSocialLogin('Phone'),
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
