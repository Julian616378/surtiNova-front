import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:surti_nova/core/theme/app_theme.dart';
import 'package:surti_nova/modules/asesor/models/tienda_model.dart';
import 'package:surti_nova/modules/asesor/services/asesor_service.dart';

/// Pantalla principal del asesor. Muestra la ruta de tiendas/prospectos
/// pendientes de visitar hoy, ordenada por cercanía a su ubicación
/// actual. Tocar una tienda abre Google Maps con la dirección para que
/// el asesor se desplace; el botón "Registrar visita" se usa cuando ya
/// habló con el cliente, de regreso en la app.
class VisitarPage extends StatefulWidget {
  const VisitarPage({super.key});

  @override
  State<VisitarPage> createState() => _VisitarPageState();
}

class _VisitarPageState extends State<VisitarPage> {
  final _svc = AsesorService.instance;

  List<TiendaModel> _ruta = [];
  bool _loading = true;
  String? _error;
  Position? _posicion;

  @override
  void initState() {
    super.initState();
    _cargarRuta();
  }

  Future<void> _cargarRuta() async {
    setState(() { _loading = true; _error = null; });
    try {
      await _obtenerUbicacion();
      _ruta = await _svc.getRutaHoy(
        lat: _posicion?.latitude,
        lng: _posicion?.longitude,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Si el usuario no da permiso de ubicación, seguimos sin reordenar
  /// (el backend ya maneja el caso lat/lng nulos).
  Future<void> _obtenerUbicacion() async {
    try {
      final permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        final nuevo = await Geolocator.requestPermission();
        if (nuevo == LocationPermission.denied ||
            nuevo == LocationPermission.deniedForever) {
          return;
        }
      }
      if (permiso == LocationPermission.deniedForever) return;

      _posicion = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
    } catch (_) {
      // sin GPS disponible: la lista llega sin reordenar, no es fatal
    }
  }

  Future<void> _abrirMaps(TiendaModel? tienda, {String? direccionTexto}) async {
    Uri uri;
    if (tienda?.latitud != null && tienda?.longitud != null) {
      uri = Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=${tienda!.latitud},${tienda.longitud}');
    } else {
      final destino = Uri.encodeComponent(direccionTexto ?? tienda?.direccion ?? '');
      uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$destino');
    }
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _snack('No se pudo abrir Google Maps', error: true);
    }
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white)),
      backgroundColor: error ? AppColors.inactiva : AppColors.activa,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // ── Flujo: registrar resultado de la visita ──────────────────────
  Future<void> _abrirResultado(TiendaModel tienda) async {
    final resultado = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _SheetOpciones(tienda: tienda),
    );
    if (resultado == null) return;

    switch (resultado) {
      case 'registrada':
        await _flujoRegistrada(tienda);
        break;
      case 'no_acepto':
      case 'no_estaba':
        await _flujoSimple(tienda, resultado);
        break;
      case 'muestra_entregada':
        await _flujoMuestra(tienda);
        break;
    }
  }

  Future<void> _enviar(TiendaModel tienda, String resultado, Map<String, dynamic> extra) async {
    try {
      // 1) crear la visita "en blanco" sobre esta tienda. rutaHoy() solo
      // devuelve tiendas que ya existen en la tabla `tiendas` (incluye
      // prospectos ya registrados), así que siempre hay id_tienda real.
      final visita = await _svc.crearVisita({
        'id_tienda': tienda.id,
        'fecha_programada': DateTime.now().toIso8601String().split('T').first,
      });
      // 2) registrar el resultado con sus datos propios
      await _svc.registrarResultado(visita.id!, {
        'resultado_visita': resultado,
        ...extra,
      });
      _snack('Visita registrada');
      _cargarRuta();
    } catch (e) {
      if (e is DioException) {
        debugPrint('STATUS: ${e.response?.statusCode}');
        debugPrint('BODY: ${e.response?.data}');
      }
      _snack('No se pudo registrar la visita', error: true);
    }
  }

  Future<void> _flujoSimple(TiendaModel tienda, String resultado) async {
    final obsCtrl = TextEditingController();
    final ok = await _dialogoObservacion(
      titulo: resultado == 'no_acepto' ? 'No aceptó' : 'No estaba',
      controller: obsCtrl,
    );
    if (ok != true) return;
    await _enviar(tienda, resultado, {'observaciones': obsCtrl.text});
  }

  Future<void> _flujoRegistrada(TiendaModel tienda) async {
    // Si la "tienda" en la ruta ya es una tienda real (cartera con
    // próxima visita vencida), solo confirmamos; si es un prospecto sin
    // datos completos, completamos el formulario de registro.
    final formCompleto = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _FormRegistrar(tienda: tienda),
    );
    if (formCompleto == null) return;
    await _enviar(tienda, 'registrada', formCompleto);
  }

  Future<void> _flujoMuestra(TiendaModel tienda) async {
    final form = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const _FormMuestra(),
    );
    if (form == null) return;
    await _enviar(tienda, 'muestra_entregada', form);
  }

  Future<bool?> _dialogoObservacion({required String titulo, required TextEditingController controller}) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(titulo),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Observaciones (opcional)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Guardar')),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _cargarRuta,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 130,
              pinned: true,
              backgroundColor: AppColors.primary,
              automaticallyImplyLeading: false,
              actions: [
                IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _cargarRuta),
              ],
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Container(
                  color: AppColors.primary,
                  padding: const EdgeInsets.fromLTRB(20, 56, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('Ruta de hoy 🗺️',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(
                        _posicion != null
                            ? '${_ruta.length} paradas ordenadas por cercanía'
                            : '${_ruta.length} paradas pendientes',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_loading)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
            else if (_error != null)
              SliverFillRemaining(child: _estadoError())
            else if (_ruta.isEmpty)
              SliverFillRemaining(child: _estadoVacio())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _tarjetaParada(i, _ruta[i]),
                    childCount: _ruta.length,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_location_alt_outlined, color: Colors.white),
        label: const Text('Agregar parada', style: TextStyle(color: Colors.white)),
        onPressed: _agregarProspectoSuelto,
      ),
    );
  }

  Widget _estadoError() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.cloud_off_outlined, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            const Text('Error al cargar la ruta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _cargarRuta, child: const Text('Reintentar')),
          ]),
        ),
      );

  Widget _estadoVacio() => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.celebration_outlined, size: 56, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          const Text('¡Sin visitas pendientes!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          const Text('Toda tu cartera está al día', style: AppTextStyles.caption),
        ]),
      );

  Widget _tarjetaParada(int index, TiendaModel t) {
    final color = estadoColor(t.estado ?? 'prospecto');
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text('${index + 1}', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(t.displayName, style: AppTextStyles.label, overflow: TextOverflow.ellipsis)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Text(estadoLabel(t.estado ?? 'prospecto'),
                  style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.location_on_outlined, size: 16, color: AppColors.subtle),
            const SizedBox(width: 4),
            Expanded(
              child: Text(t.direccion ?? '—', style: AppTextStyles.caption, overflow: TextOverflow.ellipsis),
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.map_outlined, size: 18),
                label: const Text('Ir en Maps'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary),
                ),
                onPressed: () => _abrirMaps(t),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit_note, size: 18, color: Colors.white),
                label: const Text('Registrar', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: () => _abrirResultado(t),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  /// Permite que el asesor agregue manualmente un prospecto suelto que
  /// va a visitar hoy aunque no esté programado por proxima_visita
  /// (ej: alguien que vio en la calle camino a otra tienda).
  Future<void> _agregarProspectoSuelto() async {
    final nombreCtrl = TextEditingController();
    final dirCtrl = TextEditingController();
    final telCtrl = TextEditingController();

    final agregar = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 12, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Agregar parada', style: AppTextStyles.heading),
            const SizedBox(height: 16),
            TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre del lugar/tienda')),
            const SizedBox(height: 10),
            TextField(controller: dirCtrl, decoration: const InputDecoration(labelText: 'Dirección')),
            const SizedBox(height: 10),
            TextField(controller: telCtrl, decoration: const InputDecoration(labelText: 'Teléfono (opcional)')),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Agregar a la ruta')),
          ],
        ),
      ),
    );

    if (agregar != true || nombreCtrl.text.isEmpty) return;

    try {
      // rutaHoy() solo lee de la tabla `tiendas`, así que para que esta
      // parada aparezca en la ruta hay que crearla como prospecto real
      // (estado: prospecto), no como una visita suelta sin tienda.
      await _svc.registrarProspecto({
        'nombre_establecimiento': nombreCtrl.text,
        'direccion': dirCtrl.text,
        if (telCtrl.text.isNotEmpty) 'telefono': telCtrl.text,
      });
      _snack('Parada agregada a tu ruta');
      _cargarRuta();
    } catch (_) {
      _snack('No se pudo agregar la parada', error: true);
    }
  }
}

// ── Sheet: elegir qué pasó en la visita ─────────────────────────────
class _SheetOpciones extends StatelessWidget {
  final TiendaModel tienda;
  const _SheetOpciones({required this.tienda});

  @override
  Widget build(BuildContext context) {
    final opciones = [
      ('registrada', 'Aceptó: registrar tienda', Icons.check_circle_outline, AppColors.activa),
      ('no_acepto', 'No aceptó', Icons.cancel_outlined, AppColors.inactiva),
      ('no_estaba', 'No estaba / cerrado', Icons.schedule_outlined, AppColors.prospecto),
      ('muestra_entregada', 'Dejó producto de prueba', Icons.inventory_2_outlined, AppColors.primary),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Text(tienda.displayName, style: AppTextStyles.heading),
          const Text('¿Qué pasó en la visita?', style: AppTextStyles.caption),
          const SizedBox(height: 16),
          ...opciones.map((o) => ListTile(
                leading: Icon(o.$3, color: o.$4),
                title: Text(o.$2),
                onTap: () => Navigator.pop(context, o.$1),
              )),
        ],
      ),
    );
  }
}

// ── Form: registrar tienda nueva (resultado = registrada) ──────────
class _FormRegistrar extends StatefulWidget {
  final TiendaModel tienda;
  const _FormRegistrar({required this.tienda});

  @override
  State<_FormRegistrar> createState() => _FormRegistrarState();
}

class _FormRegistrarState extends State<_FormRegistrar> {
  late final nombreCtrl = TextEditingController(text: widget.tienda.nombre);
  final propCtrl = TextEditingController();
  final telCtrl = TextEditingController();
  late final dirCtrl = TextEditingController(text: widget.tienda.direccion);
  final correoCtrl = TextEditingController();
  final nitCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 12, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Registrar tienda', style: AppTextStyles.heading),
            const SizedBox(height: 16),
            TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre *')),
            const SizedBox(height: 10),
            TextField(controller: propCtrl, decoration: const InputDecoration(labelText: 'Propietario *')),
            const SizedBox(height: 10),
            TextField(controller: telCtrl, decoration: const InputDecoration(labelText: 'Teléfono *'), keyboardType: TextInputType.phone),
            const SizedBox(height: 10),
            TextField(controller: dirCtrl, decoration: const InputDecoration(labelText: 'Dirección *')),
            const SizedBox(height: 10),
            TextField(controller: correoCtrl, decoration: const InputDecoration(labelText: 'Correo (opcional)')),
            const SizedBox(height: 10),
            TextField(controller: nitCtrl, decoration: const InputDecoration(labelText: 'NIT (opcional)')),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, {
                'nombre': nombreCtrl.text,
                'propietario': propCtrl.text,
                'telefono': telCtrl.text,
                'direccion': dirCtrl.text,
                if (correoCtrl.text.isNotEmpty) 'correo': correoCtrl.text,
                if (nitCtrl.text.isNotEmpty) 'nit': nitCtrl.text,
                if (widget.tienda.latitud != null) 'latitud': widget.tienda.latitud,
                if (widget.tienda.longitud != null) 'longitud': widget.tienda.longitud,
              }),
              child: const Text('Confirmar registro'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Form: muestra de producto entregada ─────────────────────────────
class _FormMuestra extends StatefulWidget {
  const _FormMuestra();

  @override
  State<_FormMuestra> createState() => _FormMuestraState();
}

class _FormMuestraState extends State<_FormMuestra> {
  final productoCtrl = TextEditingController(); // TODO: reemplazar por selector real de productos
  final cantidadCtrl = TextEditingController();
  DateTime? fechaRevision;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 12, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Producto de prueba entregado', style: AppTextStyles.heading),
          const Text('El repartidor lo recogerá en la próxima visita de revisión',
              style: AppTextStyles.caption),
          const SizedBox(height: 16),
          TextField(
            controller: productoCtrl,
            decoration: const InputDecoration(labelText: 'ID del producto *', hintText: 'Selector pendiente de conectar'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: cantidadCtrl,
            decoration: const InputDecoration(labelText: 'Cantidad *'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            icon: const Icon(Icons.calendar_today_outlined, size: 18),
            label: Text(fechaRevision == null
                ? 'Fecha de revisión (opcional)'
                : 'Revisar: ${fechaRevision!.toLocal().toString().split(' ').first}'),
            onPressed: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 7)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 60)),
              );
              if (d != null) setState(() => fechaRevision = d);
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, {
              'id_producto': int.tryParse(productoCtrl.text) ?? 0,
              'cantidad': int.tryParse(cantidadCtrl.text) ?? 1,
              if (fechaRevision != null)
                'fecha_revision': fechaRevision!.toIso8601String().split('T').first,
            }),
            child: const Text('Confirmar entrega'),
          ),
        ],
      ),
    );
  }
}