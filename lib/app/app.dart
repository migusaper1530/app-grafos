import 'package:flutter/material.dart';

import '../screens/menu_principal_screen.dart';
import 'app_theme.dart';
import 'app_theme_controller.dart';

/// Raíz de la aplicación.
///
/// Mantiene la configuración global fuera de `main.dart`, de modo que el
/// punto de entrada sea pequeño y esta clase pueda usarse en las pruebas.
class LogiVerseApp extends StatefulWidget {
  const LogiVerseApp({super.key});

  @override
  State<LogiVerseApp> createState() => _LogiVerseAppState();
}

class _LogiVerseAppState extends State<LogiVerseApp> {
  late final AppThemeController _themeController;

  @override
  void initState() {
    super.initState();
    _themeController = AppThemeController();
  }

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppThemeScope(
      controller: _themeController,
      child: AnimatedBuilder(
        animation: _themeController,
        builder: (context, _) => MaterialApp(
          title: 'LogiVerse Core',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: _themeController.mode,
          home: const MenuPrincipalScreen(),
        ),
      ),
    );
  }
}
