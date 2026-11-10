import 'package:flutter/material.dart';
import '../utils/colors.dart';

/// Generic placeholder shown for app sections that haven't been built yet.
/// Used by the bottom-nav tabs while each module is developed one at a time.
class WorkInProgressScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? message;

  const WorkInProgressScreen({
    super.key,
    required this.title,
    required this.icon,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary, size: 44),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Work in Progress',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message ??
                    'This section is under construction. We\'re building it module by module — check back soon!',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
