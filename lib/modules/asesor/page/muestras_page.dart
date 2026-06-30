import 'package:flutter/material.dart';
import 'package:surti_nova/modules/asesor/models/muestra_model.dart';
import 'package:surti_nova/modules/asesor/services/asesor_service.dart';

class MuestrasPage extends StatefulWidget {
  const MuestrasPage({super.key});
 
  @override
  State<MuestrasPage> createState() => _MuestrasPageState();
}
 
class _MuestrasPageState extends State<MuestrasPage> {
  final _svc = AsesorService.instance;
  List<MuestraModel> _muestras = [];
  bool _loading = false;
  String? _error;
 
  @override
  void initState() {
    super.initState();
    _load();
  }
 
  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      _muestras = await _svc.getMuestras();
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() => _loading = false);
    }
  }
 
  void _showSnack(String msg, {bool isError = false}) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ));
 
  // ── Crear muestra ────────────────────────────────────────────
  void _crearMuestra() {
    final tiendaCtrl    = TextEditingController();
    final productoCtrl  = TextEditingController(); // ✅ id numérico del producto
    final cantCtrl      = TextEditingController();
    final fechaCtrl     = TextEditingController(
        text: DateTime.now().toIso8601String().substring(0, 10));
    final fechaRevCtrl  = TextEditingController();
 
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 16, right: 16, top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Nueva Muestra',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _field('ID Tienda *', tiendaCtrl,
                  type: TextInputType.number),
              _field('ID Producto *', productoCtrl,  // ✅ int, no nombre
                  type: TextInputType.number),
              _field('Cantidad *', cantCtrl,
                  type: TextInputType.number),
              _field('Fecha entrega * (YYYY-MM-DD)', fechaCtrl),
              _field('Fecha revisión (YYYY-MM-DD)', fechaRevCtrl),
              ElevatedButton(
                onPressed: () async {
                  final idTienda   = int.tryParse(tiendaCtrl.text.trim());
                  final idProducto = int.tryParse(productoCtrl.text.trim());
                  final cantidad   = int.tryParse(cantCtrl.text.trim());
 
                  if (idTienda == null || idProducto == null || cantidad == null) {
                    _showSnack('✗ ID Tienda, ID Producto y Cantidad son numéricos',
                        isError: true);
                    return;
                  }
                  Navigator.pop(context);
                  try {
                    await _svc.crearMuestra({
                      'id_tienda':      idTienda,     // ✅ campo correcto
                      'id_producto':    idProducto,   // ✅ campo correcto (int)
                      'cantidad':       cantidad,
                      'fecha_entrega':  fechaCtrl.text.trim(),
                      if (fechaRevCtrl.text.trim().isNotEmpty)
                        'fecha_revision': fechaRevCtrl.text.trim(),
                    });
                    _showSnack('✓ Muestra creada');
                    _load();
                  } catch (e) {
                    _showSnack('✗ $e', isError: true);
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
 
  // ── Detalle + seguimiento ────────────────────────────────────
  void _showDetalle(MuestraModel m) {
    // ✅ El backend requiere: cantidad_vendida, cantidad_devuelta,
    //    valor_cobrado, fecha — todos son requeridos
    final vendidaCtrl   = TextEditingController();
    final devueltaCtrl  = TextEditingController();
    final valorCtrl     = TextEditingController();
    final fechaCtrl     = TextEditingController(
        text: DateTime.now().toIso8601String().substring(0, 10));
    final obsCtrl       = TextEditingController();
 
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 16, right: 16, top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Muestra #${m.id} · ${m.producto ?? '—'}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              // Info de la muestra
              _detRow('Tienda', m.tienda?.displayName ?? '${m.idTienda}'),
              _detRow('Producto', m.producto ?? '${m.idProducto}'),
              _detRow('Cantidad', '${m.cantidad}'),
              _detRow('Fecha entrega', m.fechaEntrega),
              _detRow('Fecha revisión', m.fechaRevision),
              _detRow('Estado', m.estado),
              if (m.extra != null)
                ...m.extra!.entries.map((e) => _detRow(e.key, '${e.value}')),
              const SizedBox(height: 16),
              // Solo seguimiento si no está cerrada
              if (m.estado == 'entregado') ...[
                const Text('Agregar Seguimiento',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _field('Cantidad vendida *', vendidaCtrl,
                    type: TextInputType.number),
                _field('Cantidad devuelta *', devueltaCtrl,
                    type: TextInputType.number),
                _field('Valor cobrado *', valorCtrl,
                    type: const TextInputType.numberWithOptions(decimal: true)),
                _field('Fecha * (YYYY-MM-DD)', fechaCtrl),
                _field('Observaciones', obsCtrl, maxLines: 2),
                ElevatedButton(
                  onPressed: () async {
                    final vendida  = int.tryParse(vendidaCtrl.text.trim());
                    final devuelta = int.tryParse(devueltaCtrl.text.trim());
                    final valor    = double.tryParse(valorCtrl.text.trim());
 
                    if (vendida == null || devuelta == null || valor == null ||
                        fechaCtrl.text.trim().isEmpty) {
                      _showSnack('✗ Todos los campos con * son requeridos',
                          isError: true);
                      return;
                    }
                    Navigator.pop(context);
                    try {
                      final res = await _svc.seguimientoMuestra(m.id, {
                        'cantidad_vendida':  vendida,   // ✅ campo correcto
                        'cantidad_devuelta': devuelta,  // ✅ campo correcto
                        'valor_cobrado':     valor,     // ✅ campo correcto
                        'fecha':             fechaCtrl.text.trim(), // ✅ requerido
                        if (obsCtrl.text.trim().isNotEmpty)
                          'observaciones': obsCtrl.text.trim(),
                      });
                      _showSnack('✓ ${res['message'] ?? 'Seguimiento guardado'}');
                      _load();
                    } catch (e) {
                      _showSnack('✗ $e', isError: true);
                    }
                  },
                  child: const Text('Guardar Seguimiento'),
                ),
              ] else
                Chip(
                  label: Text('Estado: ${m.estado}'),
                  backgroundColor:
                      m.estado == 'vendido' ? Colors.green : Colors.orange,
                  labelStyle: const TextStyle(color: Colors.white),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
 
  // ── Helpers UI ───────────────────────────────────────────────
  Widget _detRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        Text('$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600)),
        Expanded(child: Text(value)),
      ]),
    );
  }
 
  Widget _field(String label, TextEditingController ctrl,
      {TextInputType type = TextInputType.text, int maxLines = 1}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: ctrl,
          keyboardType: type,
          maxLines: maxLines,
          decoration: InputDecoration(
              labelText: label, border: const OutlineInputBorder()),
        ),
      );
 
  Color _estadoColor(String? estado) {
    switch (estado) {
      case 'entregado': return Colors.blue;
      case 'vendido':   return Colors.green;
      case 'devuelto':  return Colors.orange;
      default:          return Colors.grey;
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Muestras / Pruebas'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load)
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.science),
        label: const Text('Nueva Muestra'),
        onPressed: _crearMuestra,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                  ElevatedButton(
                      onPressed: _load, child: const Text('Reintentar')),
                ]))
              : _muestras.isEmpty
                  ? const Center(child: Text('Sin muestras registradas'))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
                      itemCount: _muestras.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 4),
                      itemBuilder: (_, i) {
                        final m = _muestras[i];
                        return ListTile(
                          tileColor: Colors.grey.shade100,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          leading: CircleAvatar(
                            backgroundColor: _estadoColor(m.estado),
                            child: const Icon(Icons.science,
                                color: Colors.white, size: 18),
                          ),
                          title: Text(m.producto ?? 'Muestra #${m.id}'),
                          subtitle: Text(
                              'Cant: ${m.cantidad} · ${m.estado}'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _showDetalle(m),
                        );
                      },
                    ),
    );
  }
}
 