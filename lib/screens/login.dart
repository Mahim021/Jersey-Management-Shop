import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/text_styles.dart';
import '../widgets/app_logo.dart';
import '../widgets/btn_primary.dart';
import '../widgets/btn_secondary.dart';
import '../widgets/input_field.dart';
import '../widgets/social_btn.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLogin = true; // true = Login, false = Sign Up
  bool _isLoading = false;

  @override
  void dispose() {
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
    
    // TODO: Implement actual sign in logic
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _handleSocialLogin(String provider) {
    // TODO: Implement social login
    debugPrint('Login with $provider');
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
                  const SizedBox(height: 12),
                  // Forgot password
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
                  const SizedBox(height: 24),
                  // Sign In button
                  PrimaryButton(
                    text: 'Sign In',
                    onPressed: _handleSignIn,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 32),
                  // OR divider
                  Text(
                    AppConstants.orContinueWith,
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
                          // TODO: Open terms
                        },
                        child: Text(
                          AppConstants.termsOfService,
                          style: AppTextStyles.footer,
                        ),
                      ),
                      Text('  •  ', style: AppTextStyles.footer),
                      TextButton(
                        onPressed: () {
                          // TODO: Open privacy
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
