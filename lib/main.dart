import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/app_theme.dart';
import 'services/session_service.dart';
import 'telas/telas.dart';

/// Inicializa dependências globais e inicia a aplicação Flutter.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR');
  runApp(const SafeRouteApp());
}

/// Define a rota nomeada da tela de login.
const String loginRoute = '/login';
/// Define a rota nomeada da tela inicial.
const String homeRoute = '/home';
/// Define a rota nomeada da lista completa de eventos.
const String eventsRoute = '/events';
/// Define a rota nomeada do formulário de cadastro de eventos.
const String createEventRoute = '/create-event';

/// Observa mudanças de rota para atualizar telas quando o usuário retorna.
final RouteObserver<PageRoute<dynamic>> appRouteObserver =
    RouteObserver<PageRoute<dynamic>>();

/// Configura tema, localização e navegação global do aplicativo.
class SafeRouteApp extends StatelessWidget {
  const SafeRouteApp({super.key});

  @override
  /// Monta o MaterialApp principal com temas claro e escuro dinâmicos.
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamicColor, darkDynamicColor) {
        return MaterialApp(
          title: 'SafeRoute',
          debugShowCheckedModeBanner: false,
          locale: const Locale('pt', 'BR'),
          supportedLocales: const [Locale('pt', 'BR')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          navigatorObservers: [appRouteObserver],
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

/// Decide se o usuário deve iniciar na home ou voltar para o login.
class AppStartScreen extends StatelessWidget {
  const AppStartScreen({super.key});

  @override
  /// Consulta a sessão salva e renderiza a primeira tela adequada.
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
