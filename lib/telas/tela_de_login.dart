import 'package:flutter/material.dart';

import '../core/app_styles.dart';
import '../main.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/session_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _submitError;

  String _formatAuthError(Object error) {
    final rawMessage = error.toString().trim();

    if (rawMessage.isEmpty) {
      return 'Erro inesperado ao autenticar.';
    }

    const prefixes = <String>[
      'Exception: ',
      'ClientException: ',
      'Bad state: ',
    ];

    for (final prefix in prefixes) {
      if (rawMessage.startsWith(prefix) && rawMessage.length > prefix.length) {
        return rawMessage.substring(prefix.length).trim();
      }
    }

    return rawMessage;
  }

  void _showAuthError(String message) {
    final errorMessage = message.trim().isEmpty
        ? 'Erro inesperado ao autenticar.'
        : message.trim();
    final colorScheme = Theme.of(context).colorScheme;

    setState(() {
      _submitError = errorMessage;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          errorMessage,
          style: TextStyle(color: colorScheme.onError),
        ),
        backgroundColor: colorScheme.error,
        showCloseIcon: true,
      ),
    );
  }

  String? _validateEmail(String? value) {
    final email = (value ?? '').trim();

    if (email.isEmpty) {
      return 'Informe seu e-mail.';
    }

    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(email)) {
      return 'Digite um e-mail válido.';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return 'Informe sua senha.';
    }

    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final senha = _passwordController.text;

    setState(() {
      _isLoading = true;
      _submitError = null;
    });

    try {
      final auth = await _authService.login(email: email, senha: senha);

      await SessionService.saveUserSession(
        userId: auth.userId,
        email: auth.email,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(auth.message)));
      await Future.delayed(AppStyles.feedbackDelay);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, homeRoute);
    } on ApiException catch (e) {
      if (!mounted) return;
      _showAuthError(
        e.message.isEmpty
            ? 'Não foi possível entrar. Tente novamente.'
            : e.message,
      );
    } catch (e) {
      if (!mounted) return;
      _showAuthError(_formatAuthError(e));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppStyles.pagePadding,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppStyles.contentMaxWidth,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'SafeRoute',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontSize: AppStyles.headerSize,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    AppStyles.gap8,
                    Text(
                      'Acesse sua conta para continuar',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: AppStyles.subtitleSize,
                      ),
                    ),
                    AppStyles.gap32,
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: _validateEmail,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        hintText: 'Digite seu e-mail',
                      ),
                    ),
                    AppStyles.gap16,
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      validator: _validatePassword,
                      onFieldSubmitted: (_) {
                        if (!_isLoading) {
                          _submit();
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        hintText: 'Digite sua senha',
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                    ),
                    if (_submitError != null) ...[
                      AppStyles.gap16,
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(
                            AppStyles.cardRadius,
                          ),
                        ),
                        padding: AppStyles.compactPadding,
                        child: Text(
                          _submitError!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colorScheme.onErrorContainer),
                        ),
                      ),
                    ],
                    AppStyles.gap24,
                    FilledButton(
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const SizedBox(
                              width: AppStyles.busyIndicatorSize,
                              height: AppStyles.busyIndicatorSize,
                              child: CircularProgressIndicator(
                                strokeWidth: AppStyles.busyIndicatorStrokeWidth,
                              ),
                            )
                          : const Text('Entrar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
