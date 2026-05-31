import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/app_config.dart';
import '../models/auth_response.dart';
import 'api_service.dart';

class AuthService {
  AuthService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Uri _uri(String path) {
    final base = Uri.parse(AppConfig.apiBaseUrl);
    return base.replace(path: '${base.path}$path'.replaceAll('//', '/'));
  }

  Future<AuthResponse> login({
    required String email,
    required String senha,
  }) async {
    final response = await _client.post(
      _uri('/auth'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'senha': senha, 'acao': 'login'}),
    );

    final data = _decodeResponse(response);
    if ((data['status'] ?? '').toString() != 'sucesso') {
      throw ApiException(
        (data['mensagem'] ?? 'Não foi possível fazer login.').toString(),
        statusCode: response.statusCode,
      );
    }

    return AuthResponse.fromJson(data);
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    Map<String, dynamic> data;

    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } on FormatException {
      throw ApiException(
        'Resposta inválida do servidor.',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode >= 400) {
      throw ApiException(
        (data['mensagem'] ?? 'Erro na comunicação com o servidor.').toString(),
        statusCode: response.statusCode,
      );
    }

    return data;
  }
}
