import 'package:flutter/material.dart';

import 'client.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeClient();
  runApp(const VasooliApp());
}

/// Vasooli — GST-correct invoicing and UPI payment tracking for Indian
/// freelancers. The Flutter tier talks only to the generated typed client;
/// every GST rule lives on the server.
class VasooliApp extends StatelessWidget {
  const VasooliApp({super.key});

  static const _saffron = Color(0xFFE8710A);
  static const _ink = Color(0xFF1B1B1F);

  ThemeData _theme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _saffron,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          brightness == Brightness.light ? const Color(0xFFFAF7F2) : _ink,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        color: brightness == Brightness.light
            ? Colors.white
            : scheme.surfaceContainerHigh,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vasooli — GST invoices that get you paid',
      debugShowCheckedModeBanner: false,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      home: const DashboardScreen(),
    );
  }
}
