import 'package:surti_nova/modules/asesor/models/tienda_model.dart';
class VisitaModel {
  final int id;
  final int idTienda;
  final int? idAsesor;
  final String? fechaProgramada;
  final String? fechaRealizada;
  final String? objetivo;
  final String? resultado;
  final String? observaciones;
  final String estado;
  final TiendaModel? tienda;
  final Map<String, dynamic>? extra; // ← agregado

  VisitaModel({
    required this.id,
    required this.idTienda,
    this.idAsesor,
    this.fechaProgramada,
    this.fechaRealizada,
    this.objetivo,
    this.resultado,
    this.observaciones,
    required this.estado,
    this.tienda,
    this.extra, // ← agregado
  });

  factory VisitaModel.fromJson(Map<String, dynamic> j) => VisitaModel(
        id:              j['id'],
        idTienda:        j['id_tienda'],
        idAsesor:        j['id_asesor'],
        fechaProgramada: j['fecha_programada'],
        fechaRealizada:  j['fecha_realizada'],
        objetivo:        j['objetivo'],
        resultado:       j['resultado'],
        observaciones:   j['observaciones'],
        estado:          j['estado'] ?? 'programada',
        tienda: j['tienda'] != null
            ? TiendaModel.fromJson(j['tienda'])
            : null,
        extra: j['extra'] != null
            ? Map<String, dynamic>.from(j['extra'])
            : null, // ← agregado
      );
}