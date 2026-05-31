import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';

class SignInTitle extends StatelessWidget {
  const SignInTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text('Fazer login', style: AppTextStyles.headlineMedium),
        SizedBox(height: 8),
        Text(
          'Insira seu e-mail caso já tenha uma conta',
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
