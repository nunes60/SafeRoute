import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safe_route/services/session_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('SessionService requires both user id and email', () async {
    SharedPreferences.setMockInitialValues({'usuario_id': 3});

    expect(await SessionService.hasSession(), isFalse);

    SharedPreferences.setMockInitialValues({
      'usuario_id': 3,
      'usuario_email': 'aluno@saferoute.com',
    });

    final session = await SessionService.getCurrentSession();

    expect(await SessionService.hasSession(), isTrue);
    expect(session?.userId, 3);
    expect(session?.email, 'aluno@saferoute.com');
  });
}
