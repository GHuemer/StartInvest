import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/router/app_routes.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_logo.dart';
import '../widgets/auth_terms_text.dart';

enum _PasswordStrength { fraca, moderada, forte }

const _kSpecialChars = {'@', '#', '%', '&', '!', '+'};

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  DateTime? _selectedBirthDate;
  _PasswordStrength? _passwordStrength;
  final _birthDateController = TextEditingController();

  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.(br|com|net|org)$',
  );
  static final _usernameRegex = RegExp(r'^[a-zA-Z0-9._]+$');
  static const _specialChars = _kSpecialChars;

  @override
  void dispose() {
    _usernameController.dispose();
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(2000),
      firstDate: DateTime(1906),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
        _birthDateController.text = _formatDate(picked);
      });
      _formKey.currentState?.validate();
    }
  }

  String? _validatePassword(String value) {
    final name = _nicknameController.text.trim().toLowerCase();
    final year = _selectedBirthDate?.year.toString() ?? '';
    final specials = value
        .split('')
        .where((c) => _specialChars.contains(c))
        .length;

    if (value.length < 6 || value.length > 20) return 'Senha inválida.';
    if (specials < 1) return 'Senha inválida.';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Senha inválida.';
    if (!RegExp(r'[a-zA-Z]').hasMatch(value)) return 'Senha inválida.';
    if (name.isNotEmpty && value.toLowerCase().contains(name))
      return 'Senha inválida.';
    if (year.isNotEmpty && value.contains(year)) return 'Senha inválida.';
    return null;
  }

  _PasswordStrength _computeStrength(String value) {
    final specials = value
        .split('')
        .where((c) => _specialChars.contains(c))
        .length;
    final numbers = value
        .split('')
        .where((c) => RegExp(r'[0-9]').hasMatch(c))
        .length;
    final uppers = value
        .split('')
        .where((c) => RegExp(r'[A-Z]').hasMatch(c))
        .length;
    if (value.length > 12 && specials > 1 && numbers > 1 && uppers > 1) {
      return _PasswordStrength.forte;
    }
    if (value.length > 8 && specials >= 1 && numbers >= 1 && uppers >= 1) {
      return _PasswordStrength.moderada;
    }
    return _PasswordStrength.fraca;
  }

  void _onPasswordChanged(String value) {
    final strength = _validatePassword(value) == null
        ? _computeStrength(value)
        : null;
    setState(() => _passwordStrength = strength);
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        AuthSignUpRequested(
          username: _usernameController.text.trim().toLowerCase(),
          name: _nicknameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          birthDate: _selectedBirthDate!,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(AppRoutes.home);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.textNegative,
            ),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 48),
                  const AuthLogo(),
                  const SizedBox(height: 32),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Criar conta',
                          style: AppTextStyles.headlineLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Escolha seu nome de usuário e apelido',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  // CAMPO: Nome de Usuário (Username)
                  TextFormField(
                    controller: _usernameController,
                    keyboardType: TextInputType.text,
                    autocorrect: false,
                    textCapitalization: TextCapitalization.none,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[a-zA-Z0-9._]'),
                      ),
                    ],
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    style: AppTextStyles.bodyLarge,
                    decoration: const InputDecoration(
                      hintText: 'Nome de usuário (ex: joao_invest)',
                      helperText: 'Este nome será usado para adicionar amigos.',
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
                  const SizedBox(height: 12),
                  // CAMPO: Nome (Apelido)
                  TextFormField(
                    controller: _nicknameController,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    style: AppTextStyles.bodyLarge,
                    decoration: const InputDecoration(
                      hintText: 'Como quer ser chamado? (Apelido)',
                    ),
                    onChanged: (_) {
                      // Revalida senha caso o nome mude (regra: senha não pode conter nome)
                      if (_passwordController.text.isNotEmpty) {
                        _onPasswordChanged(_passwordController.text);
                      }
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'O apelido é obrigatório';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  // CAMPO: Data de Nascimento
                  GestureDetector(
                    onTap: _pickBirthDate,
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: _birthDateController,
                        readOnly: true,
                        style: AppTextStyles.bodyLarge,
                        decoration: const InputDecoration(
                          hintText: 'Data de nascimento',
                          suffixIcon: Icon(Icons.calendar_today_outlined),
                        ),
                        validator: (_) {
                          if (_selectedBirthDate == null)
                            return 'Ano inválido.';
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // CAMPO: E-mail
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    style: AppTextStyles.bodyLarge,
                    decoration: const InputDecoration(
                      hintText: 'email@dominio.com',
                    ),
                    validator: (value) {
                      final email = value?.trim() ?? '';
                      if (email.isEmpty || !_emailRegex.hasMatch(email)) {
                        return 'Formato de email inválido.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  // CAMPO: Senha
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    style: AppTextStyles.bodyLarge,
                    onChanged: _onPasswordChanged,
                    decoration: InputDecoration(
                      hintText: 'Senha',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.textMuted,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'A senha é obrigatória';
                      return _validatePassword(value);
                    },
                  ),
                  // Checklist de requisitos da senha
                  if (_passwordController.text.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _PasswordRequirements(
                      password: _passwordController.text,
                      name: _nicknameController.text.trim().toLowerCase(),
                      birthYear: _selectedBirthDate?.year.toString(),
                    ),
                  ],
                  // Indicador de força da senha
                  if (_passwordStrength != null) ...[
                    const SizedBox(height: 6),
                    _PasswordStrengthIndicator(strength: _passwordStrength!),
                  ],
                  const SizedBox(height: 12),
                  // CAMPO: Confirmar Senha
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirm,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    style: AppTextStyles.bodyLarge,
                    decoration: InputDecoration(
                      hintText: 'Confirmar senha',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.textMuted,
                        ),
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'As senhas não coincidem';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      return ElevatedButton(
                        onPressed: isLoading ? null : _onSubmit,
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: AppColors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Criar conta'),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'Já tem uma conta? ',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                          TextSpan(
                            text: 'Entrar',
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const AuthTermsText(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordStrengthIndicator extends StatelessWidget {
  const _PasswordStrengthIndicator({required this.strength});

  final _PasswordStrength strength;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (strength) {
      _PasswordStrength.fraca => ('fraca', Colors.red),
      _PasswordStrength.moderada => ('moderada', Colors.amber),
      _PasswordStrength.forte => ('forte', Colors.green),
    };
    final fillFraction = switch (strength) {
      _PasswordStrength.fraca => 1 / 3,
      _PasswordStrength.moderada => 2 / 3,
      _PasswordStrength.forte => 1.0,
    };

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fillFraction,
              color: color,
              backgroundColor: color.withValues(alpha: 0.2),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Senha $label',
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _PasswordRequirements extends StatelessWidget {
  const _PasswordRequirements({
    required this.password,
    required this.name,
    this.birthYear,
  });

  final String password;
  final String name;
  final String? birthYear;

  @override
  Widget build(BuildContext context) {
    final specials = password
        .split('')
        .where((c) => _kSpecialChars.contains(c))
        .length;
    final showNameRule = name.isNotEmpty || birthYear != null;
    final nameOk =
        (name.isEmpty || !password.toLowerCase().contains(name)) &&
        (birthYear == null || !password.contains(birthYear!));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CheckItem(
          '6 a 20 caracteres',
          password.length >= 6 && password.length <= 20,
        ),
        _CheckItem(
          'Pelo menos 1 caractere especial (@, #, %, &, !, +)',
          specials >= 1,
        ),
        _CheckItem('Pelo menos 1 número', RegExp(r'[0-9]').hasMatch(password)),
        _CheckItem(
          'Pelo menos 1 letra (a-z, A-Z)',
          RegExp(r'[a-zA-Z]').hasMatch(password),
        ),
        if (showNameRule)
          _CheckItem('Não contém seu nome ou ano de nascimento', nameOk),
      ],
    );
  }
}

class _CheckItem extends StatelessWidget {
  const _CheckItem(this.label, this.met);

  final String label;
  final bool met;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle : Icons.radio_button_unchecked,
            color: met ? Colors.green : Colors.grey,
            size: 16,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: met ? Colors.green : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
