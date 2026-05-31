import 'package:flutter_test/flutter_test.dart';
import 'package:safe_route/models/evento.dart';

void main() {
  test('Evento.fromJson parses a valid payload', () {
    final evento = Evento.fromJson({
      'id': 12,
      'nome_disciplina': 'Linguagem de Programação Mobile',
      'descricao_atividade': 'Entrega final',
      'data_entrega': '2026-06-30',
    });

    expect(evento.id, 12);
    expect(evento.nomeDisciplina, 'Linguagem de Programação Mobile');
    expect(evento.descricaoAtividade, 'Entrega final');
    expect(evento.dataEntrega, DateTime(2026, 6, 30));
  });

  test('Evento.fromJson throws on invalid payload', () {
    expect(
      () => Evento.fromJson({
        'id': 12,
        'nome_disciplina': 'Linguagem de Programação Mobile',
        'descricao_atividade': '',
        'data_entrega': 'data-invalida',
      }),
      throwsFormatException,
    );
  });
}
