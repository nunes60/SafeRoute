import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safe_route/services/api_exception.dart';
import 'package:safe_route/services/auth_service.dart';
import 'package:safe_route/services/session_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('AuthService.signIn saves the current session', () async {
    final service = AuthService(
      client: MockClient((request) async {
        expect(request.url.path, '/auth');
        return http.Response(
          jsonEncode({
            'status': 'sucesso',
            'mensagem': 'Login realizado com sucesso.',
            'usuario': {'id': 7, 'email': 'aluno@saferoute.com'},
          }),
          200,
        );
      }),
    );

    final response = await service.signIn(
      email: 'aluno@saferoute.com',
      senha: '123456',
    );
    final session = await SessionService.getCurrentSession();

    expect(response.userId, 7);
    expect(response.email, 'aluno@saferoute.com');
    expect(session?.userId, 7);
    expect(session?.email, 'aluno@saferoute.com');
  });

  test('AuthService.login throws ApiException on invalid payload', () async {
    final service = AuthService(
      client: MockClient((request) async {
        return http.Response(
          jsonEncode({
            'status': 'sucesso',
            'usuario': {'id': 'abc', 'email': ''},
          }),
          200,
        );
      }),
    );

    expect(
      () => service.login(email: 'aluno@saferoute.com', senha: '123456'),
      throwsA(isA<ApiException>()),
    );
  });
}
