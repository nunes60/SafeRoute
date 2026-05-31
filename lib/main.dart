import 'package:flutter/material.dart';

import 'services/session_service.dart';
import 'telas/telas.dart';

void main() {
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
    return MaterialApp(
      title: 'SafeRoute',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const AppStartScreen(),
      routes: {
        loginRoute: (context) => const LoginPage(),
        homeRoute: (context) => const WelcomeScreen(),
        eventsRoute: (context) => const EventListScreen(),
        createEventRoute: (context) => const CadastrarEventoScreen(),
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