import 'package:surti_nova/modules/asesor/models/tienda_model.dart';
/// Espejo de la tabla `visita_comercials` del backend real (la que está
/// en VisitaComercialController). Una visita puede apuntar a una tienda
/// que ya existe en cartera (id_tienda) o a un prospecto suelto que el
/// asesor visita por primera vez sin tienda creada todavía (campos
/// *_prospecto), y registra qué pasó en `resultado_visita`.
class VisitaModel {
  final int? id;
  final TiendaModel? tienda;

  final String? nombreProspecto;
  final String? telefonoProspecto;
  final String? direccionProspecto;
  final double? latitudProspecto;
  final double? longitudProspecto;

  /// registrada | no_acepto | no_estaba | muestra_entregada
  final String? resultadoVisita;
  final String? observaciones;
  final DateTime? proximaVisita;
  final DateTime? fecha;
  final int? idMuestra;

  VisitaModel({
    this.id,
    this.tienda,
    this.nombreProspecto,
    this.telefonoProspecto,
    this.direccionProspecto,
    this.latitudProspecto,
    this.longitudProspecto,
    this.resultadoVisita,
    this.observaciones,
    this.proximaVisita,
    this.fecha,
    this.idMuestra,
  });

  String get nombreMostrar => tienda?.displayName ?? nombreProspecto ?? 'Sin nombre';
  String? get direccionMostrar => tienda?.direccion ?? direccionProspecto;
  String? get telefonoMostrar => tienda?.telefono ?? telefonoProspecto;
  double? get latMostrar => tienda?.latitud ?? latitudProspecto;
  double? get lngMostrar => tienda?.longitud ?? longitudProspecto;
  bool get esProspectoNuevo => tienda == null;

  factory VisitaModel.fromJson(Map<String, dynamic> json) {
    return VisitaModel(
      id: json['id'] as int?,
      tienda: json['tienda'] != null ? TiendaModel.fromJson(json['tienda']) : null,
      nombreProspecto: json['nombre_prospecto'] as String?,
      telefonoProspecto: json['telefono_prospecto'] as String?,
      direccionProspecto: json['direccion_prospecto'] as String?,
      latitudProspecto: json['latitud_prospecto'] != null
          ? double.tryParse(json['latitud_prospecto'].toString())
          : null,
      longitudProspecto: json['longitud_prospecto'] != null
          ? double.tryParse(json['longitud_prospecto'].toString())
          : null,
      resultadoVisita: json['resultado_visita'] as String?,
      observaciones: json['observaciones'] as String?,
      proximaVisita: json['proxima_visita'] != null
          ? DateTime.tryParse(json['proxima_visita'])
          : null,
      fecha: json['fecha'] != null ? DateTime.tryParse(json['fecha']) : null,
      idMuestra: json['id_muestra'] as int?,
    );
  }
}