import '../models/evento.dart';
import 'api_exception.dart';
import 'api_service.dart';
import 'session_service.dart';

/// Expõe operações de eventos já vinculadas ao usuário em sessão.
class EventService {
  EventService({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  /// Lista os eventos do usuário atual, com limite opcional.
  Future<List<Evento>> listEventos({int? limit}) async {
    final session = await _requireSession();
    return _apiService.listarEventos(usuarioId: session.userId, limit: limit);
  }

  /// Cria um evento usando o usuário salvo na sessão atual.
  Future<void> salvarEvento({
    required String nomeDisciplina,
    required String descricaoAtividade,
    required String dataEntrega,
  }) async {
    final session = await _requireSession();
    await _apiService.salvarEvento(
      usuarioId: session.userId,
      nomeDisciplina: nomeDisciplina,
      descricaoAtividade: descricaoAtividade,
      dataEntrega: dataEntrega,
    );
  }

  /// Atualiza um evento existente do usuário autenticado.
  Future<void> editarEvento({
    required int eventoId,
    required String nomeDisciplina,
    required String descricaoAtividade,
    required String dataEntrega,
  }) async {
    final session = await _requireSession();
    await _apiService.editarEvento(
      eventoId: eventoId,
      usuarioId: session.userId,
      nomeDisciplina: nomeDisciplina,
      descricaoAtividade: descricaoAtividade,
      dataEntrega: dataEntrega,
    );
  }

  /// Exclui um evento do usuário autenticado e retorna seu identificador.
  Future<int> excluirEvento({required int eventoId}) async {
    final session = await _requireSession();
    return _apiService.excluirEvento(
      eventoId: eventoId,
      usuarioId: session.userId,
    );
  }

  /// Garante que exista uma sessão válida antes de acessar a API.
  Future<SessionData> _requireSession() async {
    final session = await SessionService.getCurrentSession();
    if (session != null) {
      return session;
    }

    throw ApiException('Sessão não encontrada. Faça login novamente.');
  }
}
