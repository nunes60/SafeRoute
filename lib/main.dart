import 'package:flutter/material.dart';

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
        colorSchemeSeed: const Color(0xFF1B5E20),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(),
        ),
      ),
      initialRoute: loginRoute,
      routes: {
        loginRoute: (context) => const LoginPage(),
        homeRoute: (context) => const WelcomeScreen(),
        eventsRoute: (context) => const EventListScreen(),
        createEventRoute: (context) => const CadastrarEventoScreen(),
      },
    );
  }
}
import 'package:flutter/material.dart';

import 'telas/telas.dart';

void main() {
  runApp(const SafeRouteApp());
}

<<<<<<< HEAD
=======
const String loginRoute = '/login';
const String homeRoute = '/home';
const String eventsRoute = '/events';
const String createEventRoute = '/create-event';

>>>>>>> 9f77c06 (Corrige navegacao entre telas)
class SafeRouteApp extends StatelessWidget {
  const SafeRouteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeRoute',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1B5E20),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(),
        ),
      ),
<<<<<<< HEAD
      home: const LoginPage(),
=======
      initialRoute: loginRoute,
      routes: {
        loginRoute: (context) => const LoginPage(),
        homeRoute: (context) => const WelcomeScreen(),
        eventsRoute: (context) => const EventListScreen(),
        createEventRoute: (context) => const CadastrarEventoScreen(),
      },
>>>>>>> 9f77c06 (Corrige navegacao entre telas)
    );
  }
}