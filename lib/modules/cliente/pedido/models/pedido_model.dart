class PedidoDetalleModel {
  final int    id;
  final int    idProducto;
  final String nombreProducto;
  final String? imagenProducto;
  final int    cantidad;
  final double precioUnitario;
  final double subtotal;

  PedidoDetalleModel({
    required this.id,
    required this.idProducto,
    required this.nombreProducto,
    this.imagenProducto,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  factory PedidoDetalleModel.fromJson(Map<String, dynamic> j) => PedidoDetalleModel(
    id:             j['id'] ?? 0,
    idProducto:     j['id_producto'] ?? 0,
    nombreProducto: j['producto']?['nombre'] ?? '',
    imagenProducto: j['producto']?['imagen'],
    cantidad:       j['cantidad'] ?? 0,
    precioUnitario: double.tryParse(j['precio_unitario'].toString()) ?? 0,
    subtotal:       double.tryParse(j['subtotal'].toString()) ?? 0,
  );
}

class PedidoModel {
  final int    id;
  final String estado;
  final double total;
  final String? notas;
  final String  fechaCreacion;
  final List<PedidoDetalleModel> detalles;

  PedidoModel({
    required this.id,
    required this.estado,
    required this.total,
    this.notas,
    required this.fechaCreacion,
    required this.detalles,
  });

  factory PedidoModel.fromJson(Map<String, dynamic> j) => PedidoModel(
    id:            j['id'] ?? 0,
    estado:        j['estado'] ?? 'pendiente',
    total:         double.tryParse(j['total'].toString()) ?? 0,
    notas:         j['notas'],
    fechaCreacion: j['created_at'] ?? '',
    detalles: (j['detalles'] as List? ?? [])
        .map((d) => PedidoDetalleModel.fromJson(d))
        .toList(),
  );
}