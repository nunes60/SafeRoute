import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safe_route/services/api_exception.dart';
import 'package:safe_route/services/api_service.dart';
import 'package:safe_route/services/event_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('EventService.listEventos uses the saved session', () async {
    SharedPreferences.setMockInitialValues({
      'usuario_id': 9,
      'usuario_email': 'aluno@saferoute.com',
    });

    final service = EventService(
      apiService: ApiService(
        client: MockClient((request) async {
          expect(request.url.queryParameters['usuario_id'], '9');
          expect(request.url.queryParameters['limit'], '1');
          return http.Response(
            jsonEncode({
              'status': 'sucesso',
              'eventos': [
                {
                  'id': 1,
                  'nome_disciplina': 'Projeto Integrador',
                  'descricao_atividade': 'Apresentação final',
                  'data_entrega': '2026-07-01',
                },
              ],
            }),
            200,
          );
        }),
      ),
    );

    final eventos = await service.listEventos(limit: 1);

    expect(eventos, hasLength(1));
    expect(eventos.single.nomeDisciplina, 'Projeto Integrador');
  });

  test('EventService.listEventos throws when there is no session', () async {
    final service = EventService(
      apiService: ApiService(
        client: MockClient((request) async {
          return http.Response('{}', 200);
        }),
      ),
    );

    expect(() => service.listEventos(), throwsA(isA<ApiException>()));
  });
}
