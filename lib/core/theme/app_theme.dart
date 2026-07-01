import 'package:flutter/material.dart';

// ── Colores ──────────────────────────────────────────────────
class AppColors {
  AppColors._();

  static const primary   = Color(0xFFE8500A); // naranja SurtiNova
  static const onPrimary = Colors.white;

  static const background = Color(0xFFF5F5F5);
  static const surface    = Colors.white;
  static const onSurface  = Color(0xFF1A1A1A);
  static const subtle     = Color(0xFF666666);

  // estados tienda
  static const prospecto  = Color(0xFFF97316); // naranja
  static const registrada = Color(0xFF3B82F6); // azul
  static const enPrueba   = Color(0xFF8B5CF6); // morado
  static const activa     = Color(0xFF22C55E); // verde
  static const inactiva   = Color(0xFFEF4444); // rojo
}

// ── Textos ───────────────────────────────────────────────────
class AppTextStyles {
  AppTextStyles._();

  static const heading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.onSurface,
  );

  static const body = TextStyle(
    fontSize: 14,
    color: AppColors.onSurface,
  );

  static const caption = TextStyle(
    fontSize: 12,
    color: AppColors.subtle,
  );

  static const label = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );
}

// ── Iconos por estado ────────────────────────────────────────
class AppIcons {
  AppIcons._();

  static IconData estadoIcon(String? estado) {
    switch (estado) {
      case 'prospecto':  return Icons.person_outline;
      case 'registrada': return Icons.store;
      case 'en_prueba':  return Icons.science_outlined;
      case 'activa':     return Icons.check_circle_outline;
      case 'inactiva':   return Icons.cancel_outlined;
      default:           return Icons.store;
    }
  }
}

// ── Theme ────────────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      surface: AppColors.surface,
      background: AppColors.background,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}

// ── Helper color de estado ───────────────────────────────────
Color estadoColor(String? estado) {
  switch (estado) {
    case 'prospecto':  return AppColors.prospecto;
    case 'registrada': return AppColors.registrada;
    case 'en_prueba':  return AppColors.enPrueba;
    case 'activa':     return AppColors.activa;
    case 'inactiva':   return AppColors.inactiva;
    default:           return Colors.grey;
  }
}

String estadoLabel(String? estado) {
  switch (estado) {
    case 'prospecto':  return 'Prospecto';
    case 'registrada': return 'Registrada';
    case 'en_prueba':  return 'En prueba';
    case 'activa':     return 'Activa';
    case 'inactiva':   return 'Inactiva';
    default:           return estado ?? '—';
  }
}