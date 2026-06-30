import 'package:flutter/material.dart';
import 'core/services/api_service.dart';
import 'core/theme/app_theme.dart';

import 'modules/auth/splash_page.dart';
import 'modules/auth/login_page.dart';

import 'modules/dashboard/admin_dashboard_page.dart';
import 'modules/dashboard/asesor_dashboard_page.dart';
import 'modules/cliente/dashboard/views/cliente_dashboard_page.dart';


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
      theme: AppTheme.theme,
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashPage(),
        '/login': (_) => const LoginPage(),

        // Dashboards según el rol
        '/admin-dashboard': (_) => const AdminDashboardPage(),
        '/asesor-dashboard': (_) => const AsesorDashboardPage(),
       '/cliente-dashboard': (_) => const ClienteDashboardPage(),
        
        
      },
    );
  }
}