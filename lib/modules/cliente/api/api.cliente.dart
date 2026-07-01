class ApiCliente {
  // Catálogo
  static const String categorias = '/categorias';
  static const String productos = '/productos';
  static const String ofertas = '/ofertas';

  // Pedidos del cliente (tienda)
  static const String pedidos = '/tienda/pedidos';
  static const String misPedidos = '/tienda/mis-pedidos';

  // Carrito
  static const String carrito = '/carrito';
  static const String confirmarCarrito = '/carrito/confirmar';

  static String productoDetalle(int id) => '/productos/$id';
  static String categoriaDetalle(int id) => '/categorias/$id';
  static String pedidoDetalle(int id) => '/tienda/pedidos/$id';
}