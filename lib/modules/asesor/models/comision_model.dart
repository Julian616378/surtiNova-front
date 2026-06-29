import 'tienda_model.dart';

class ComisionModel {
  final int id;
  final int? idTienda;
  final String? concepto;
  final double valor;
  final String estado;
  final String? fecha;
  final TiendaModel? tienda;

  ComisionModel({
    required this.id,
    this.idTienda,
    this.concepto,
    required this.valor,
    required this.estado,
    this.fecha,
    this.tienda,
  });

  // Aliases que usa comisiones_page.dart
  double? get monto => valor;
  String? get periodo => fecha;

  factory ComisionModel.fromJson(Map<String, dynamic> j) => ComisionModel(
        id:       j['id'],
        idTienda: j['id_tienda'],
        concepto: j['concepto'],
        valor:    (j['valor'] as num?)?.toDouble() ?? 0,
        estado:   j['estado'] ?? '—',
        fecha:    j['fecha'],
        tienda: j['tienda'] != null
            ? TiendaModel.fromJson(j['tienda'])
            : null,
      );
}
// Wrapper para el response completo de misComisiones
class ComisionesResponse {
  final List<ComisionModel> comisiones;
  final double totalPendiente;
  final double totalPagado;

  ComisionesResponse({
    required this.comisiones,
    required this.totalPendiente,
    required this.totalPagado,
  });

  factory ComisionesResponse.fromJson(Map<String, dynamic> j) {
    final paginado = j['comisiones'];
    final lista = paginado is Map
        ? (paginado['data'] as List? ?? [])
        : (paginado as List? ?? []);

    return ComisionesResponse(
      comisiones:      lista.map((e) => ComisionModel.fromJson(e)).toList(),
      totalPendiente:  (j['total_pendiente'] as num?)?.toDouble() ?? 0,
      totalPagado:     (j['total_pagado']    as num?)?.toDouble() ?? 0,
    );
  }
}