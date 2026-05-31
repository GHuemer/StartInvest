import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/auth_bloc.dart';

class SignInEmailForm extends StatefulWidget {
  const SignInEmailForm({super.key});

  @override
  State<SignInEmailForm> createState() => _SignInEmailFormState();
}

class _SignInEmailFormState extends State<SignInEmailForm> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            AuthSignInWithEmailRequested(
              email: _emailController.text.trim(),
              password: '',
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: AppTextStyles.bodyLarge,
            decoration: const InputDecoration(hintText: 'email@dominio.com'),
            validator: (value) {
              final email = value?.trim() ?? '';
              
              if (email.isEmpty) {
                return 'O e-mail é obrigatório';
              }

              final emailRegex = RegExp(
                r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
              );

              if (!emailRegex.hasMatch(email)) {
                return 'Por favor, insira um e-mail válido';
              }

              return null;
            },
          ),
          const SizedBox(height: 12),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final isLoading = state is AuthLoading;
              return ElevatedButton(
                onPressed: isLoading ? null : _onContinue,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: AppColors.white, strokeWidth: 2))
                    : const Text('Continuar'),
              );
            },
          ),
        ],
      ),
    );
  }
}
