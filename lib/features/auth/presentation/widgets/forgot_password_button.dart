import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';

class ForgotPasswordButton extends StatelessWidget {
  const ForgotPasswordButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {},
      child: const Text('Esqueci a senha', style: AppTextStyles.bodyMedium),
    );
  }
}
