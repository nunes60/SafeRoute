import 'package:flutter/material.dart';

import '../core/app_styles.dart';
import '../main.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;

  Future<void> _submit(String acao) async {
    final email = _emailController.text.trim();
    final senha = _passwordController.text.trim();

    if (email.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha e-mail e senha.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final auth = await _apiService.auth(
        email: email,
        senha: senha,
        acao: acao,
      );

      await SessionService.saveUserSession(userId: auth.userId, email: auth.email);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.message)),
      );
      Navigator.pushReplacementNamed(context, homeRoute);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro inesperado ao autenticar.')),
      );
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
    return Scaffold(
      // Contêiner principal da tela de autenticação.
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppStyles.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppStyles.gap64,
              // Título da aplicação exibido no topo da tela.
              Text(
                'SafeRoute',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: AppStyles.headerSize,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              AppStyles.gap8,
              Text(
                'LOGIN',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: AppStyles.subtitleSize,
                    ),
              ),
              AppStyles.gap32,

              // Campo para o usuário informar o e-mail.
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Usuário',
                  hintText: 'Digite seu e-mail',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => _emailController.clear(),
                  ),
                ),
              ),
              AppStyles.gap16,

              // Campo para o usuário informar a senha.
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  hintText: 'Digite sua senha',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => _passwordController.clear(),
                  ),
                ),
              ),
              AppStyles.gap24,

              // Ação principal para login na API.
              FilledButton.icon(
                onPressed: _isLoading ? null : () => _submit('login'),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('ENTRAR'),
              ),
              AppStyles.gap12,
              // Ação secundária para cadastro usando o mesmo formulário.
              OutlinedButton.icon(
                onPressed: _isLoading ? null : () => _submit('cadastro'),
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('CADASTRAR'),
              ),
              if (_isLoading) ...[
                AppStyles.gap16,
                // Indicador visual enquanto a autenticação está em andamento.
                const Center(child: CircularProgressIndicator()),
              ],
            ],
          ),
        ),
      ),
    );
  }
}