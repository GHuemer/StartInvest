import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/router/app_routes.dart';
import '../bloc/auth_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/di/injection.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  final _usernameRegex = RegExp(r"^[a-zA-Z0-9._]+$");

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final username = _usernameController.text.trim().toLowerCase();
      final authRepo = getIt<AuthRepository>();
      final currentUser = authRepo.currentUser;

      if (currentUser != null) {
        final result = await authRepo.updateUsername(currentUser.id, username);
        result.fold(
          (failure) => setState(() {
            _errorMessage = failure.message;
            _isLoading = false;
          }),
          (_) async {
            // Recarrega o estado do usuário no Bloc para refletir a mudança
            final authBloc = context.read<AuthBloc>();
            authBloc.add(const AuthStarted());
            
            // Aguarda um pouco para o redirecionamento acontecer via router
            // ou navega manualmente para garantir
            context.go(AppRoutes.home);
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Quase lá!',
                  style: AppTextStyles.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Escolha um nome de usuário único para ser encontrado pelos seus amigos.',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _usernameController,
                  autofocus: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9._]')),
                  ],
                  decoration: InputDecoration(
                    hintText: 'Nome de usuário',
                    errorText: _errorMessage,
                    prefixIcon: const Icon(Icons.alternate_email),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'O nome de usuário é obrigatório';
                    }
                    if (value.length < 3) {
                      return 'Mínimo de 3 caracteres';
                    }
                    if (!_usernameRegex.hasMatch(value)) {
                      return 'Use apenas letras, números, pontos ou underlines';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _onSave,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Concluir Cadastro'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
