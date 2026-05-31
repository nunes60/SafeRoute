import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safe_route/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AppStartScreen shows login when session is missing', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MaterialApp(home: AppStartScreen()));
    await tester.pumpAndSettle();

    expect(find.text('SafeRoute'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
