import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/legal_texts.dart';
import '../utils/text_styles.dart';
import '../widgets/info_dialog.dart';
import '../widgets/primary_button.dart';
import 'main_shell.dart';
import 'otp_verification.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
  String _selectedCountryCode = '+1';
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String _buildE164PhoneNumber() {
    final digits = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    var phone = '$_selectedCountryCode$digits';
    if (!phone.startsWith('+')) {
      phone = '+880$phone';
    }
    return phone;
  }

  Future<void> _sendOTP() async {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final phoneNumber = _buildE164PhoneNumber();

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          final userCredential =
              await FirebaseAuth.instance.signInWithCredential(credential);
          final isNewUser =
              userCredential.additionalUserInfo?.isNewUser ?? false;
          final uid = userCredential.user?.uid;
          if (isNewUser && uid != null) {
            UserService().createUserDocument(uid, phone: phoneNumber).ignore();
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
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Automatic verification failed. Please try again')),
          );
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        final message = switch (e.code) {
          'operation-not-allowed' =>
            'Phone sign-in is disabled. Enable it in Firebase Console → Authentication → Sign-in method.',
          'invalid-phone-number' => 'Invalid phone number. Please check the number and try again.',
          'quota-exceeded' => 'SMS quota exceeded. Please try again later.',
          'network-request-failed' => 'No internet connection. Please check your network.',
          _ => e.message ?? 'Phone verification failed. Please try again.',
        };
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), duration: const Duration(seconds: 6)),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPVerificationScreen(
              phoneNumber: phoneNumber,
              verificationId: verificationId,
            ),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  void _showLegalDialog(String title, String content) {
    InfoDialog.show(context, title, content);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/kimmich.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.bgOverlay,
          ),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                  // Back button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(height: 60),
                  
                  // Heading
                  Text(
                    'Enter Phone Number',
                    style: AppTextStyles.heading1.copyWith(fontSize: 32),
                  ),
                  const SizedBox(height: 16),
                  
                  // Subtitle
                  Text(
                    'We\'ll send you a one-time verification code to\nsecurely access your Jersey Hub account.',
                    style: AppTextStyles.inputLabel.copyWith(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Mobile number label
                  Text(
                    'MOBILE NUMBER',
                    style: AppTextStyles.inputLabel.copyWith(
                      letterSpacing: 1,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Phone input with country code
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Country code dropdown
                      Container(
                        width: 120,
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.inputBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.inputBorder,
                            width: 1,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCountryCode,
                            icon: Icon(Icons.keyboard_arrow_down, 
                              color: Colors.grey[400]),
                            dropdownColor: AppColors.inputBg,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: '+1',
                                child: Row(
                                  children: [
                                    Text('🇺🇸', style: TextStyle(fontSize: 20)),
                                    SizedBox(width: 8),
                                    Text('+1'),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: '+44',
                                child: Row(
                                  children: [
                                    Text('🇬🇧', style: TextStyle(fontSize: 20)),
                                    SizedBox(width: 8),
                                    Text('+44'),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: '+91',
                                child: Row(
                                  children: [
                                    Text('🇮🇳', style: TextStyle(fontSize: 20)),
                                    SizedBox(width: 8),
                                    Text('+91'),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: '+880',
                                child: Row(
                                  children: [
                                    Text('🇧🇩', style: TextStyle(fontSize: 20)),
                                    SizedBox(width: 8),
                                    Text('+880'),
                                  ],
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedCountryCode = value);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Phone number input
                      Expanded(
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.inputBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.inputBorder,
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              hintText: '000 000 0000',
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 16,
                              ),
                              prefixIcon: Icon(
                                Icons.phone,
                                color: Colors.grey[400],
                                size: 22,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Send OTP button
                  PrimaryButton(
                    text: 'Send OTP',
                    onPressed: _sendOTP,
                    isLoading: _isLoading,
                    icon: Icons.arrow_forward,
                  ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Terms and Privacy fixed at bottom
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => _showLegalDialog(
                          AppConstants.termsOfService,
                          LegalTexts.termsOfService,
                        ),
                        child: Text(
                          AppConstants.termsOfService,
                          style: AppTextStyles.footer,
                        ),
                      ),
                      Text('  •  ', style: AppTextStyles.footer),
                      TextButton(
                        onPressed: () => _showLegalDialog(
                          AppConstants.privacyPolicy,
                          LegalTexts.privacyPolicy,
                        ),
                        child: Text(
                          AppConstants.privacyPolicy,
                          style: AppTextStyles.footer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
