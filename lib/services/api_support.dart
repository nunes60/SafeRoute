import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/app_config.dart';
import 'api_exception.dart';

/// Monta a URI final da API a partir do caminho e da query informados.
Uri buildApiUri(String path, [Map<String, String>? queryParameters]) {
  final base = Uri.parse(AppConfig.apiBaseUrl);
  // replace() preserva host/protocolo e altera só os trechos necessários.
  return base.replace(
    path: '${base.path}$path'.replaceAll('//', '/'),
    queryParameters: queryParameters,
  );
}

/// Decodifica a resposta JSON e converte erros HTTP em exceções de domínio.
Map<String, dynamic> decodeApiResponse(http.Response response) {
  Map<String, dynamic> data;

  try {
    // A API deve sempre retornar um objeto JSON no corpo.
    data = jsonDecode(response.body) as Map<String, dynamic>;
  } on FormatException {
    throw ApiException(
      'Resposta invalida do servidor.',
      statusCode: response.statusCode,
    );
  }

  if (response.statusCode >= 400) {
    // Resposta HTTP de erro: mantém mensagem da API quando disponível.
    throw ApiException(
      (data['mensagem'] ?? 'Erro na comunicação com o servidor.').toString(),
      statusCode: response.statusCode,
    );
  }

  return data;
}
