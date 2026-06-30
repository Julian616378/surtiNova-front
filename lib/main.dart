import 'package:flutter/material.dart';
//import 'package:surti_nova/modules/cliente/catalogo/views/catalogo_view.dart';
import 'core/services/api_service.dart';
import 'core/theme/app_theme.dart';

import 'modules/auth/splash_page.dart';
import 'modules/auth/login_page.dart';

import 'modules/dashboard/admin_dashboard_page.dart';
import 'modules/dashboard/asesor_dashboard_page.dart';

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
      theme: AppTheme.light,
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashPage(),
        '/login': (_) => const LoginPage(),

        '/admin-dashboard': (_) => const AdminDashboardPage(),
        '/asesor-dashboard': (_) => const AsesorDashboardPage(),

       
      },
    );
  }
}