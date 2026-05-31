import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';

class RegisterButton extends StatelessWidget {
  const RegisterButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {},
      child: const Text('Registrar-se', style: AppTextStyles.titleMedium),
    );
  }
}
