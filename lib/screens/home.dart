import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../widgets/work_in_progress.dart';

class HomeContent extends StatelessWidget {
  final void Function(int)? onNavigate;
  const HomeContent({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgDark,
      child: const WorkInProgressScreen(
        title: 'Home',
        icon: Icons.home_rounded,
      ),
    );
  }
}
