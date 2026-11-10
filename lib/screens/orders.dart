import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../widgets/work_in_progress.dart';

class OrdersContent extends StatelessWidget {
  const OrdersContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgDark,
      child: const WorkInProgressScreen(
        title: 'Cart & Orders',
        icon: Icons.shopping_cart_outlined,
      ),
    );
  }
}
