class ApiConstants {
  // Cambia esto por tu URL real
  // Emulador Android  → 'http://10.0.2.2:8000/api'
  // Dispositivo físico → 'http://192.168.X.X:8000/api'
  // Producción        → 'https://tu-dominio.com/api'
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  static const String login  = '/auth/login';
  static const String logout = '/auth/logout';
  static const String me     = '/auth/me';
}