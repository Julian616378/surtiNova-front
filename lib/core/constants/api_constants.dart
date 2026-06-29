class ApiConstants {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
 
  // Auth
  static const String login  = '/login';
  static const String logout = '/auth/logout';
  static const String me     = '/auth/me';
 
  // Comercial - Asesor
  static const String prospectos  = '/comercial/prospectos';
  static const String tiendas     = '/comercial/tiendas';
  static const String cartera     = '/comercial/cartera';
  static const String visitas     = '/comercial/visitas';
  static const String muestras    = '/comercial/muestras';
  static const String comisiones  = '/comercial/mis-comisiones';
 
  // Helpers dinámicos
  static String tienda(int id)              => '/comercial/tiendas/$id';
  static String visita(int id)              => '/comercial/visitas/$id';
  static String visitaResultado(int id)     => '/comercial/visitas/$id/resultado';
  static String muestra(int id)             => '/comercial/muestras/$id';
  static String muestraSeguimiento(int id)  => '/comercial/muestras/$id/seguimiento';
}
 
