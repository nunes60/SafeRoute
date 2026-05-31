import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/app_config.dart';
import '../models/evento.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() =>
      'ApiException(statusCode: $statusCode, message: $message)';
}

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Uri _uri(String path, [Map<String, String>? queryParameters]) {
    final base = Uri.parse(AppConfig.apiBaseUrl);
    return base.replace(
      path: '${base.path}$path'.replaceAll('//', '/'),
      queryParameters: queryParameters,
    );
  }

  Future<List<Evento>> listarEventos({
    required int usuarioId,
    int? limit,
  }) async {
    final query = <String, String>{
      'usuario_id': usuarioId.toString(),
      if (limit != null) 'limit': limit.toString(),
    };

    final response = await _client.get(
      _uri('/listar_eventos', query),
      headers: const {'Content-Type': 'application/json'},
    );

    final data = _decodeResponse(response);
    if ((data['status'] ?? '').toString() != 'sucesso') {
      throw ApiException(
        (data['mensagem'] ?? 'Não foi possível listar os eventos.').toString(),
        statusCode: response.statusCode,
      );
    }

    final eventos = (data['eventos'] as List<dynamic>? ?? const []);
    return eventos
        .whereType<Map<String, dynamic>>()
        .map(Evento.fromJson)
        .toList(growable: false);
  }

  Future<int> salvarEvento({
    required int usuarioId,
    required String nomeDisciplina,
    required String descricaoAtividade,
    required String dataEntrega,
  }) async {
    final response = await _client.post(
      _uri('/salvar_evento'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'usuario_id': usuarioId,
        'nome_disciplina': nomeDisciplina,
        'descricao_atividade': descricaoAtividade,
        'data_entrega': dataEntrega,
      }),
    );

    final data = _decodeResponse(response);
    if ((data['status'] ?? '').toString() != 'sucesso') {
      throw ApiException(
        (data['mensagem'] ?? 'Falha ao salvar o evento.').toString(),
        statusCode: response.statusCode,
      );
    }

    return _parseInt(data['evento_id']);
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

  int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
