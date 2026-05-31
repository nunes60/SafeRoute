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

  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      id: _parseInt(json['evento_id'] ?? json['id_evento'] ?? json['id']),
      nomeDisciplina: (json['nome_disciplina'] ?? '').toString(),
      descricaoAtividade: (json['descricao_atividade'] ?? '').toString(),
      dataEntrega: DateTime.tryParse((json['data_entrega'] ?? '').toString()) ??
          DateTime.now(),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
