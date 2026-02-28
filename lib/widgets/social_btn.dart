import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';

class SocialButton extends StatelessWidget {
  final String text;
  final String? svgPath;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool isDark;

  const SocialButton({
    super.key,
    required this.text,
    this.svgPath,
    this.icon,
    required this.onPressed,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? AppColors.btnSecondary : Colors.white,
          foregroundColor: isDark ? AppColors.textWhite : AppColors.textDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textWhite : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (svgPath != null && svgPath!.isNotEmpty) {
      return SvgPicture.asset(
        svgPath!,
        width: 24,
        height: 24,
      );
    } else if (icon != null) {
      return Icon(
        icon,
        size: 24,
        color: isDark ? AppColors.textWhite : AppColors.textDark,
      );
    }
    return const SizedBox(width: 24, height: 24);
  }
}
