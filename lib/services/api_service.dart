import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/evento.dart';
import 'api_exception.dart';
import 'api_support.dart';

/// Executa as chamadas HTTP relacionadas ao cadastro de eventos.
class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Busca a lista de eventos do usuário autenticado.
  Future<List<Evento>> listarEventos({
    required int usuarioId,
    int? limit,
  }) async {
    final query = <String, String>{
      'usuario_id': usuarioId.toString(),
      if (limit != null) 'limit': limit.toString(),
    };

    final response = await _client.get(
      buildApiUri('/listar_eventos', query),
      headers: const {'Content-Type': 'application/json'},
    );

    final data = decodeApiResponse(response);
    if ((data['status'] ?? '').toString() != 'sucesso') {
      throw ApiException(
        (data['mensagem'] ?? 'Não foi possível listar os eventos.').toString(),
        statusCode: response.statusCode,
      );
    }

    final eventos = (data['eventos'] as List<dynamic>? ?? const []);
    try {
      return eventos
          .map((item) {
            if (item is Map<String, dynamic>) {
              return Evento.fromJson(item);
            }
            if (item is Map) {
              return Evento.fromJson(Map<String, dynamic>.from(item));
            }
            throw const FormatException('Evento invalido');
          })
          .toList(growable: false);
    } on FormatException {
      throw ApiException(
        'Resposta invalida do servidor.',
        statusCode: response.statusCode,
      );
    }
  }

  /// Envia um novo evento para persistência na API.
  Future<int> salvarEvento({
    required int usuarioId,
    required String nomeDisciplina,
    required String descricaoAtividade,
    required String dataEntrega,
  }) async {
    final response = await _client.post(
      buildApiUri('/salvar_evento'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'usuario_id': usuarioId,
        'nome_disciplina': nomeDisciplina,
        'descricao_atividade': descricaoAtividade,
        'data_entrega': dataEntrega,
      }),
    );

    final data = decodeApiResponse(response);
    if ((data['status'] ?? '').toString() != 'sucesso') {
      throw ApiException(
        (data['mensagem'] ?? 'Falha ao salvar o evento.').toString(),
        statusCode: response.statusCode,
      );
    }

    return _parseEventoId(data);
  }

  /// Atualiza um evento existente com os novos dados informados.
  Future<int> editarEvento({
    required int eventoId,
    required int usuarioId,
    required String nomeDisciplina,
    required String descricaoAtividade,
    required String dataEntrega,
  }) async {
    final response = await _client.post(
      buildApiUri('/editar_evento'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'evento_id': eventoId,
        'usuario_id': usuarioId,
        'nome_disciplina': nomeDisciplina,
        'descricao_atividade': descricaoAtividade,
        'data_entrega': dataEntrega,
      }),
    );

    final data = decodeApiResponse(response);
    if ((data['status'] ?? '').toString() != 'sucesso') {
      throw ApiException(
        (data['mensagem'] ?? 'Falha ao editar o evento.').toString(),
        statusCode: response.statusCode,
      );
    }

    return _parseEventoId(data);
  }

  /// Solicita a exclusão de um evento específico do usuário.
  Future<int> excluirEvento({
    required int eventoId,
    required int usuarioId,
  }) async {
    final response = await _client.post(
      buildApiUri('/excluir_evento'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'evento_id': eventoId, 'usuario_id': usuarioId}),
    );

    final data = decodeApiResponse(response);
    if ((data['status'] ?? '').toString() != 'sucesso') {
      throw ApiException(
        (data['mensagem'] ?? 'Falha ao excluir o evento.').toString(),
        statusCode: response.statusCode,
      );
    }

    return _parseEventoId(data);
  }

  /// Converte diferentes formatos numéricos retornados pela API em int.
  int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  /// Extrai o identificador do evento a partir das chaves aceitas pela API.
  int _parseEventoId(Map<String, dynamic> data) {
    return _parseInt(data['evento_id'] ?? data['id_evento'] ?? data['id']);
  }
}
