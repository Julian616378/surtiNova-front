import 'package:surti_nova/modules/asesor/models/tienda_model.dart'; // ← esto faltaba

class ProductoBasico {
  final int id;
  final String nombre;

  ProductoBasico({required this.id, required this.nombre});

  factory ProductoBasico.fromJson(Map<String, dynamic> j) =>
      ProductoBasico(id: j['id'], nombre: j['nombre'] ?? '—');
}

class MuestraModel {
  final int id;
  final int idTienda;
  final int idProducto;
  final int cantidad;
  final String fechaEntrega;
  final String? fechaRevision;
  final String estado;
  final TiendaModel? tienda;
  final ProductoBasico? productoObj;
  final Map<String, dynamic>? extra;

  MuestraModel({
    required this.id,
    required this.idTienda,
    required this.idProducto,
    required this.cantidad,
    required this.fechaEntrega,
    this.fechaRevision,
    required this.estado,
    this.tienda,
    this.productoObj,
    this.extra,
  });

  String? get producto => productoObj?.nombre;

  factory MuestraModel.fromJson(Map<String, dynamic> j) => MuestraModel(
        id:            j['id'],
        idTienda:      j['id_tienda'],
        idProducto:    j['id_producto'],
        cantidad:      j['cantidad'],
        fechaEntrega:  j['fecha_entrega'],
        fechaRevision: j['fecha_revision'],
        estado:        j['estado'] ?? 'entregado',
        tienda: j['tienda'] != null
            ? TiendaModel.fromJson(j['tienda'])
            : null,
        productoObj: j['producto'] != null
            ? ProductoBasico.fromJson(j['producto'])
            : null,
        extra: j['extra'] != null
            ? Map<String, dynamic>.from(j['extra'])
            : null,
      );
}