import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF8BC34A), Color(0xFFFFD600)],
            ),
            border: Border.all(color: AppColors.primary, width: 3),
          ),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('START',
                    style: TextStyle(
                        color: AppColors.backgroundDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        letterSpacing: 2)),
                Icon(Icons.show_chart,
                    color: AppColors.backgroundDark, size: 32),
                Text('INVEST',
                    style: TextStyle(
                        color: AppColors.backgroundDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        letterSpacing: 2)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                  text: 'START',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white)),
              TextSpan(
                  text: ' INVEST',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w400,
                      color: AppColors.white)),
            ],
          ),
        ),
      ],
    );
  }
}
