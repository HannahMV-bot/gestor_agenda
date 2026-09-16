import 'package:flutter/material.dart';
import 'core/constants/app_theme.dart';
import 'features/auth/presentation/pages/login_page.dart';

void main() {
  runApp(const GestorAgendaApp());
}

class GestorAgendaApp extends StatelessWidget {
  const GestorAgendaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestor de Agenda',
      theme: AppTheme.lightTheme,
      home: const LoginPage(),
    );
  }
}