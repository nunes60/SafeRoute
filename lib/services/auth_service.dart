import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/auth_response.dart';
import 'api_exception.dart';
import 'api_support.dart';
import 'session_service.dart';

/// Centraliza a autenticação do usuário e a abertura da sessão local.
class AuthService {
  AuthService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Faz a chamada de login e valida a resposta recebida da API.
  Future<AuthResponse> login({
    required String email,
    required String senha,
  }) async {
    final response = await _client.post(
      buildApiUri('/auth'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'senha': senha, 'acao': 'login'}),
    );

    final data = decodeApiResponse(response);
    if ((data['status'] ?? '').toString() != 'sucesso') {
      throw ApiException(
        (data['mensagem'] ?? 'Não foi possível fazer login.').toString(),
        statusCode: response.statusCode,
      );
    }

    try {
      return AuthResponse.fromJson(data);
    } on FormatException {
      throw ApiException(
        'Resposta invalida do servidor.',
        statusCode: response.statusCode,
      );
    }
  }

  /// Realiza o login e salva a sessão do usuário no dispositivo.
  Future<AuthResponse> signIn({
    required String email,
    required String senha,
  }) async {
    final authResponse = await login(email: email, senha: senha);
    await SessionService.saveUserSession(
      userId: authResponse.userId,
      email: authResponse.email,
    );
    return authResponse;
  }
}
