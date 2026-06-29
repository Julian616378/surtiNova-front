import 'package:flutter/material.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

 Future<void> _checkSession() async {
  await Future.delayed(const Duration(seconds: 2));
  
  final hasToken = await StorageService.hasToken();
  
  if (!mounted) return;
  
  if (!hasToken) {
    Navigator.pushReplacementNamed(context, '/login');
    return;
  }

  // ✅ Leer el rol guardado para ir al dashboard correcto
  final rol = await StorageService.getRole();
  
  if (!mounted) return;
  
  switch (rol?.toLowerCase()) {
    case 'admin':
      Navigator.pushReplacementNamed(context, '/admin-dashboard');
      break;
    case 'asesor':
      Navigator.pushReplacementNamed(context, '/asesor-dashboard');
      break;
    case 'cliente':
      Navigator.pushReplacementNamed(context, '/cliente-dashboard');
      break;
    default:
      // Si el rol no se reconoce, limpiar sesión y volver al login
      await StorageService.clearSession();
      Navigator.pushReplacementNamed(context, '/login');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storefront_rounded, size: 80, color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Surti Nova',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 40),
            CircularProgressIndicator(color: Colors.white54),
          ],
        ),
      ),
    );
  }
}