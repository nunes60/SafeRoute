import '../core/json_reader.dart';

/// Representa um evento acadêmico exibido e manipulado no app.
class Evento {
  const Evento({
    required this.id,
    required this.nomeDisciplina,
    required this.descricaoAtividade,
    required this.dataEntrega,
  });

  final int id;
  final String nomeDisciplina;
  final String descricaoAtividade;
  final DateTime dataEntrega;

  /// Cria um evento a partir do payload recebido da API.
  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      id: JsonReader.requiredInt(json, const [
        'evento_id',
        'id_evento',
        'id',
      ], fieldName: 'evento_id'),
      nomeDisciplina: JsonReader.requiredNonEmptyString(json, const [
        'nome_disciplina',
      ], fieldName: 'nome_disciplina'),
      descricaoAtividade: JsonReader.requiredNonEmptyString(json, const [
        'descricao_atividade',
      ], fieldName: 'descricao_atividade'),
      dataEntrega: JsonReader.requiredDate(json, const [
        'data_entrega',
      ], fieldName: 'data_entrega'),
    );
  }
}
