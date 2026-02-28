import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/text_styles.dart';
import '../widgets/primary_button.dart';
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

  void _sendOTP() {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simulate OTP sending
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OTPVerificationScreen(
            phoneNumber: '$_selectedCountryCode ${_phoneController.text}',
          ),
        ),
      );
    });
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
                        onPressed: () {
                          // TODO: Show terms
                        },
                        child: Text(
                          AppConstants.termsOfService,
                          style: AppTextStyles.footer,
                        ),
                      ),
                      Text('  •  ', style: AppTextStyles.footer),
                      TextButton(
                        onPressed: () {
                          // TODO: Show privacy
                        },
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
