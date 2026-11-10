import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../widgets/work_in_progress.dart';

class SellerStoreContent extends StatelessWidget {
  const SellerStoreContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgDark,
      child: const WorkInProgressScreen(
        title: 'HOT',
        icon: Icons.local_fire_department,
      ),
    );
  }
}
