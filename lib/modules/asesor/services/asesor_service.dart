import 'package:surti_nova/core/services/api_service.dart';
import 'package:surti_nova/core/constants/api_constants.dart';
import '../models/tienda_model.dart';
import '../models/visita_model.dart';
import '../models/muestra_model.dart';
import '../models/comision_model.dart';

class AsesorService {
  AsesorService._();
  static final AsesorService instance = AsesorService._();

  // Laravel paginate() devuelve { data: [...], current_page, ... }
  List _pagData(dynamic body) {
    if (body is List) return body;
    if (body is Map) return (body['data'] as List?) ?? [];
    return [];
  }

  // ══════════════════════════════════════════════════════════
  // TIENDAS / PROSPECTOS
  // ══════════════════════════════════════════════════════════

  /// POST /comercial/prospectos
  /// Campos: nombre_establecimiento, nombre_propietario, telefono,
  ///         direccion, barrio*, ciudad, observaciones*
  Future<TiendaModel> registrarProspecto(Map<String, dynamic> data) async {
    final res = await ApiService.post(ApiConstants.prospectos, data);
    return TiendaModel.fromJson(res.data);
  }

  /// POST /comercial/tiendas
  /// Campos: razon_social, nit, propietario, telefono, email,
  ///         direccion, latitud*, longitud*, id_asesor*
  Future<TiendaModel> crearTienda(Map<String, dynamic> data) async {
    final res = await ApiService.post(ApiConstants.tiendas, data);
    return TiendaModel.fromJson(res.data);
  }

  /// GET /comercial/cartera  → array plano (no paginado)
  Future<List<TiendaModel>> getCartera() async {
    final res = await ApiService.get(ApiConstants.cartera);
    final list = res.data is List ? res.data as List : [];
    return list.map((e) => TiendaModel.fromJson(e)).toList();
  }

  /// GET /comercial/tiendas/{id}
  Future<TiendaModel> getTienda(int id) async {
    final res = await ApiService.get(ApiConstants.tienda(id));
    return TiendaModel.fromJson(res.data);
  }

  /// PATCH /comercial/tiendas/{id}
  /// Campos opcionales: razon_social, propietario, telefono, email,
  ///                    direccion, latitud, longitud
  Future<TiendaModel> updateTienda(int id, Map<String, dynamic> data) async {
    final res = await ApiService.patch(ApiConstants.tienda(id), data);
    return TiendaModel.fromJson(res.data);
  }

  // ══════════════════════════════════════════════════════════
  // VISITAS
  // ══════════════════════════════════════════════════════════

  /// GET /comercial/visitas  → paginado
  Future<List<VisitaModel>> getVisitas() async {
    final res = await ApiService.get(ApiConstants.visitas);
    return _pagData(res.data).map((e) => VisitaModel.fromJson(e)).toList();
  }

  /// GET /comercial/visitas/ruta-hoy?lat=..&lng=..  → NUEVO
  /// Lista de tiendas/prospectos pendientes de visitar hoy, ordenada por
  /// cercanía a la posición actual del asesor (greedy nearest-neighbor
  /// con distancia Haversine, calculado en el backend). Si se omiten
  /// lat/lng, el backend devuelve la lista sin reordenar.
  /// Respuesta del backend: { total, tiendas: [...] }
  ///
  /// Nota: ApiService.get solo acepta el path (sin queryParameters), así
  /// que el query string se construye aquí mismo y se pega a la URL.
  Future<List<TiendaModel>> getRutaHoy({double? lat, double? lng}) async {
    final params = <String>[
      if (lat != null) 'lat=$lat',
      if (lng != null) 'lng=$lng',
    ];
    final path = params.isEmpty
        ? ApiConstants.rutaHoy
        : '${ApiConstants.rutaHoy}?${params.join('&')}';

    final res = await ApiService.get(path);
    final tiendas = (res.data['tiendas'] as List?) ?? [];
    return tiendas.map((e) => TiendaModel.fromJson(e)).toList();
  }

  /// POST /comercial/visitas
  /// Campos: id_tienda, fecha_programada, objetivo*
  /// Úsalo cuando la visita es sobre una tienda que ya existe en
  /// cartera (incluye prospectos: rutaHoy() solo lee de la tabla
  /// `tiendas`, así que todo prospecto pasa primero por
  /// registrarProspecto() antes de poder tener una visita).
  Future<VisitaModel> crearVisita(Map<String, dynamic> data) async {
    final res = await ApiService.post(ApiConstants.visitas, data);
    return VisitaModel.fromJson(res.data);
  }

  /// GET /comercial/visitas/{id}
  Future<VisitaModel> getVisita(int id) async {
    final res = await ApiService.get(ApiConstants.visita(id));
    return VisitaModel.fromJson(res.data);
  }

  /// PATCH /comercial/visitas/{id}/resultado
  /// Mismo nombre y firma de siempre. Importante: el backend real espera
  /// la llave 'resultado_visita' (no 'resultado') con uno de estos 4
  /// valores: registrada | no_acepto | no_estaba | muestra_entregada.
  /// Si tu data ya trae 'resultado_visita' tal cual, no pasa nada; si
  /// trae 'resultado' a secas (como en el comentario original), este
  /// método lo traduce para no romper ningún lugar donde ya lo llamas.
  Future<VisitaModel> registrarResultado(int id, Map<String, dynamic> data) async {
    final payload = {...data};
    if (payload.containsKey('resultado') && !payload.containsKey('resultado_visita')) {
      payload['resultado_visita'] = payload.remove('resultado');
    }
    final res = await ApiService.patch(ApiConstants.visitaResultado(id), payload);
    return VisitaModel.fromJson(res.data);
  }

  // ══════════════════════════════════════════════════════════
  // MUESTRAS
  // ══════════════════════════════════════════════════════════

  /// GET /comercial/muestras  → paginado
  Future<List<MuestraModel>> getMuestras() async {
    final res = await ApiService.get(ApiConstants.muestras);
    return _pagData(res.data).map((e) => MuestraModel.fromJson(e)).toList();
  }

  /// POST /comercial/muestras
  /// Campos: id_tienda, id_producto, cantidad, fecha_entrega, fecha_revision*
  Future<MuestraModel> crearMuestra(Map<String, dynamic> data) async {
    final res = await ApiService.post(ApiConstants.muestras, data);
    return MuestraModel.fromJson(res.data);
  }

  /// GET /comercial/muestras/{id}
  Future<MuestraModel> getMuestra(int id) async {
    final res = await ApiService.get(ApiConstants.muestra(id));
    return MuestraModel.fromJson(res.data);
  }

  /// POST /comercial/muestras/{id}/seguimiento
  /// Campos: cantidad_vendida, cantidad_devuelta, valor_cobrado, fecha, observaciones*
  Future<Map<String, dynamic>> seguimientoMuestra(int id, Map<String, dynamic> data) async {
    final res = await ApiService.post(ApiConstants.muestraSeguimiento(id), data);
    return res.data;
  }

  // ══════════════════════════════════════════════════════════
  // COMISIONES
  // ══════════════════════════════════════════════════════════

  /// GET /comercial/mis-comisiones
  /// Devuelve { comisiones: paginado, total_pendiente, total_pagado }
  Future<ComisionesResponse> getMisComisiones() async {
    final res = await ApiService.get(ApiConstants.comisiones);
    return ComisionesResponse.fromJson(res.data);
  }
}