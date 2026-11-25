import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/legal_texts.dart';
import 'info_dialog.dart';

/// Slide-out menu opened from the Home header. Tapping the dimmed area
/// outside it closes it (built-in [Drawer] behaviour).
class AppDrawer extends StatelessWidget {
  /// Switches the bottom-nav tab (0 Home, 1 Explore, 2 Hot, 3 Cart, 4 Profile).
  final void Function(int) onNavigate;
  const AppDrawer({super.key, required this.onNavigate});

  void _goToTab(BuildContext context, int index) {
    Navigator.pop(context);
    onNavigate(index);
  }

  void _comingSoon(BuildContext context, String feature) {
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$feature is coming soon')));
  }

  void _showInfo(BuildContext context, String title, String content) {
    Navigator.pop(context);
    InfoDialog.show(context, title, content);
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final navigator = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2E),
        title: const Text('Log Out', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Log Out',
                style: TextStyle(color: Color(0xFFFF453A))),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      navigator.pop(); // close the drawer
      await AuthService().signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final name = (user?.displayName?.trim().isNotEmpty ?? false)
        ? user!.displayName!.trim()
        : 'JerseyHub Member';
    final email = user?.email ?? '';

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.78,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(name, email),
            const Divider(color: Colors.white12, height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _item(Icons.home_rounded, 'Home',
                      onTap: () => _goToTab(context, 0), active: true),
                  _item(Icons.explore_outlined, 'Explore',
                      onTap: () => _goToTab(context, 1)),
                  _item(Icons.category_outlined, 'Categories',
                      trailing: const Icon(Icons.chevron_right,
                          color: Colors.grey),
                      onTap: () => _goToTab(context, 1)),
                  _item(Icons.receipt_long_outlined, 'My Orders',
                      onTap: () => _goToTab(context, 3)),
                  _item(Icons.favorite_border, 'Wishlist',
                      onTap: () => _comingSoon(context, 'Wishlist')),
                  _item(Icons.notifications_none, 'Notifications',
                      onTap: () => _comingSoon(context, 'Notifications')),
                  _item(
                    Icons.storefront_outlined,
                    'Become a Seller',
                    highlight: true,
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'NEW',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () => _comingSoon(context, 'Seller registration'),
                  ),
                  _item(Icons.settings_outlined, 'Settings',
                      onTap: () => _goToTab(context, 4)),
                  const Divider(color: Colors.white12, height: 24),
                  _item(Icons.info_outline, 'About Us',
                      onTap: () => _showInfo(
                            context,
                            'About Us',
                            'JerseyHub is a marketplace for authentic sports '
                                'jerseys from trusted sellers.\n\n'
                                '${AppConstants.tagline}.',
                          )),
                  _item(Icons.description_outlined,
                      AppConstants.termsOfService,
                      onTap: () => _showInfo(context,
                          AppConstants.termsOfService, LegalTexts.termsOfService)),
                  _item(Icons.privacy_tip_outlined, AppConstants.privacyPolicy,
                      onTap: () => _showInfo(context,
                          AppConstants.privacyPolicy, LegalTexts.privacyPolicy)),
                  _item(Icons.help_outline, 'Help & Support',
                      onTap: () => _showInfo(
                          context, 'Help & Support', LegalTexts.helpCenter)),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFFFF453A)),
              title: const Text(
                'Log Out',
                style: TextStyle(
                  color: Color(0xFFFF453A),
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () => _confirmLogout(context),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                '${AppConstants.appName} v1.0.0',
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String name, String email) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (email.isNotEmpty)
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(
    IconData icon,
    String label, {
    required VoidCallback onTap,
    Widget? trailing,
    bool active = false,
    bool highlight = false,
  }) {
    final color = active || highlight ? AppColors.primary : Colors.white70;
    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(vertical: 0.5),
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(
          color: active || highlight ? AppColors.primary : Colors.white,
          fontWeight: active || highlight ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
