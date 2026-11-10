import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/colors.dart';
import '../widgets/work_in_progress.dart';

class ProfileContent extends StatelessWidget {
  const ProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgDark,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: WorkInProgressScreen(
                title: 'Profile',
                icon: Icons.person_outline_rounded,
                message:
                    'Profile details, orders, addresses and settings are being '
                    'built next. You can still log out below to test sign in/sign up.',
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: GestureDetector(
                onTap: () => _showLogoutDialog(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E22),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    bool isLoggingOut = false;
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF2A2A2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Logout',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: isLoggingOut
                  ? null
                  : () async {
                      setDialogState(() => isLoggingOut = true);
                      await AuthService().signOut();
                      // MainShell's authStateChanges listener handles
                      // navigation back to AuthScreen.
                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                      }
                    },
              child: isLoggingOut
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                      ),
                    )
                  : const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
