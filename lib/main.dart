import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/app_theme.dart';
import 'services/session_service.dart';
import 'telas/telas.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR');
  runApp(const SafeRouteApp());
}

const String loginRoute = '/login';
const String homeRoute = '/home';
const String eventsRoute = '/events';
const String createEventRoute = '/create-event';

class SafeRouteApp extends StatelessWidget {
  const SafeRouteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamicColor, darkDynamicColor) {
        return MaterialApp(
          title: 'SafeRoute',
          debugShowCheckedModeBanner: false,
          locale: const Locale('pt', 'BR'),
          supportedLocales: const [Locale('pt', 'BR')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          theme: AppTheme.light(lightDynamicColor),
          darkTheme: AppTheme.dark(darkDynamicColor),
          themeMode: ThemeMode.system,
          home: const AppStartScreen(),
          routes: {
            loginRoute: (context) => const LoginPage(),
            homeRoute: (context) => const WelcomeScreen(),
            eventsRoute: (context) => const EventListScreen(),
            createEventRoute: (context) => const CadastrarEventoScreen(),
          },
        );
      },
    );
  }
}

class AppStartScreen extends StatelessWidget {
  const AppStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: SessionService.hasSession(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == true) {
          return const WelcomeScreen();
        }

        return const LoginPage();
      },
    );
  }
}
