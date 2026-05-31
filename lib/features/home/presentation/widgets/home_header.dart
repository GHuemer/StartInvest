import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/router/app_routes.dart';

class HomeHeader extends StatelessWidget {
  final dynamic user;
  final String firstName;
  final String subtitle;

  const HomeHeader({
    super.key,
    required this.user,
    required this.firstName,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Start Invest',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: AppTextStyles.fontFamily,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Bem-vindo de volta,', style: AppTextStyles.greeting),
            const SizedBox(height: 4),
            Text('Olá, $firstName!', style: AppTextStyles.userName),
            const SizedBox(height: 4),
            Text(subtitle, style: AppTextStyles.pilarDescription),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.white, size: 28),
              onPressed: () {},
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => context.go(AppRoutes.profile),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.backgroundCard,
                child: ClipOval(
                  child: user?.photoUrl != null
                      ? Image.network(user!.photoUrl!)
                      : const Icon(Icons.person_outline, color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
