import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/text_styles.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // App name
        RichText(
          text: const TextSpan(
            style: AppTextStyles.heading1,
            children: [
              TextSpan(text: 'Jersey'),
              TextSpan(
                text: 'Hub',
                style: TextStyle(color: AppColors.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppConstants.tagline,
          style: AppTextStyles.heading2,
        ),
      ],
    );
  }
}
