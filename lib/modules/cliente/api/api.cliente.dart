class ApiCliente {
 

  static const String categorias  = '/categorias';
  static const String productos   = '/productos';
  static const String ofertas     = '/ofertas';

  static String productoDetalle(int id) => '/productos/$id';
  static String categoriaDetalle(int id) => '/categorias/$id';
}