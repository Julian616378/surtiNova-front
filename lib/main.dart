import 'package:flutter/material.dart';
import 'core/services/api_service.dart';
import 'core/theme/app_theme.dart';           // ← agrega esto
import 'modules/auth/splash_page.dart';
import 'modules/auth/login_page.dart';
import 'modules/dashboard/dashboard_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ApiService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Surti Nova',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,                  // ← usa el tema centralizado
      initialRoute: '/',
      routes: {
        '/':          (_) => const SplashPage(),
        '/login':     (_) => const LoginPage(),
        '/dashboard': (_) => const DashboardPage(),
      },
    );
  }
}