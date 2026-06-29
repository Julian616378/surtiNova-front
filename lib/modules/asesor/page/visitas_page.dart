import 'package:flutter/material.dart';
import 'package:surti_nova/modules/asesor/models/visita_model.dart';
import 'package:surti_nova/modules/asesor/services/asesor_service.dart';

class VisitasPage extends StatefulWidget {
  const VisitasPage({super.key});
 
  @override
  State<VisitasPage> createState() => _VisitasPageState();
}
 
class _VisitasPageState extends State<VisitasPage> {
  final _svc = AsesorService.instance;
  List<VisitaModel> _visitas = [];
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
      _visitas = await _svc.getVisitas();
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
 
  // ── Crear visita ─────────────────────────────────────────────
  void _crearVisita() {
    final tiendaIdCtrl = TextEditingController();
    final fechaCtrl    = TextEditingController();
    final objetivoCtrl = TextEditingController();
 
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 16, right: 16, top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Nueva Visita',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: tiendaIdCtrl,
              keyboardType: TextInputType.number,
              // ✅ El backend espera 'id_tienda', no 'tienda_id'
              decoration: const InputDecoration(
                  labelText: 'ID Tienda', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: fechaCtrl,
              decoration: const InputDecoration(
                  labelText: 'Fecha programada (YYYY-MM-DD)',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: objetivoCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                  labelText: 'Objetivo (opcional)',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final idTienda = int.tryParse(tiendaIdCtrl.text.trim());
                if (idTienda == null) {
                  _showSnack('✗ ID de tienda inválido', isError: true);
                  return;
                }
                Navigator.pop(context);
                try {
                  await _svc.crearVisita({
                    'id_tienda':        idTienda,        // ✅ campo correcto
                    'fecha_programada': fechaCtrl.text.trim(),
                    if (objetivoCtrl.text.trim().isNotEmpty)
                      'objetivo': objetivoCtrl.text.trim(),
                  });
                  _showSnack('✓ Visita creada');
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
    );
  }
 
  // ── Detalle + registrar resultado ────────────────────────────
  void _showDetalle(VisitaModel v) {
    final resultadoCtrl   = TextEditingController(text: v.resultado ?? '');
    final fechaCtrl       = TextEditingController(
        text: DateTime.now().toIso8601String().substring(0, 10));
    final observacionCtrl = TextEditingController(text: v.observaciones ?? '');
 
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
              Text('Visita #${v.id}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              // Info de la visita
              _detRow('Tienda', v.tienda?.displayName ?? '${v.idTienda}'),
              _detRow('Fecha programada', v.fechaProgramada),
              _detRow('Fecha realizada', v.fechaRealizada),
              _detRow('Objetivo', v.objetivo),
              _detRow('Estado', v.estado),
              // extra fields si vienen del backend
              if (v.extra != null)
                ...v.extra!.entries.map((e) => _detRow(e.key, '${e.value}')),
              const SizedBox(height: 16),
              // Solo mostrar formulario si no está realizada
              if (v.estado != 'realizada') ...[
                const Text('Registrar Resultado',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: resultadoCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                      labelText: 'Resultado *',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                // ✅ fecha_realizada es requerida por el backend
                TextField(
                  controller: fechaCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Fecha realizada (YYYY-MM-DD) *',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: observacionCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                      labelText: 'Observaciones (opcional)',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (resultadoCtrl.text.trim().isEmpty ||
                        fechaCtrl.text.trim().isEmpty) {
                      _showSnack('✗ Resultado y fecha son requeridos',
                          isError: true);
                      return;
                    }
                    Navigator.pop(context);
                    try {
                      await _svc.registrarResultado(v.id, {
                        'resultado':      resultadoCtrl.text.trim(),  // ✅ requerido
                        'fecha_realizada': fechaCtrl.text.trim(),     // ✅ requerido
                        if (observacionCtrl.text.trim().isNotEmpty)
                          'observaciones': observacionCtrl.text.trim(),
                      });
                      _showSnack('✓ Resultado guardado');
                      _load();
                    } catch (e) {
                      _showSnack('✗ $e', isError: true);
                    }
                  },
                  child: const Text('Registrar Resultado'),
                ),
              ] else
                const Chip(
                  label: Text('Visita ya realizada'),
                  backgroundColor: Colors.green,
                  labelStyle: TextStyle(color: Colors.white),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
 
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
 
  Color _estadoColor(String? estado) {
    switch (estado?.toLowerCase()) {
      case 'realizada':  return Colors.green;
      case 'programada': return Colors.orange;
      case 'cancelada':  return Colors.red;
      default:           return Colors.grey;
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visitas Comerciales'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load)
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Nueva Visita'),
        onPressed: _crearVisita,
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
              : _visitas.isEmpty
                  ? const Center(child: Text('Sin visitas registradas'))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
                      itemCount: _visitas.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 4),
                      itemBuilder: (_, i) {
                        final v = _visitas[i];
                        return ListTile(
                          tileColor: Colors.grey.shade100,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          leading: CircleAvatar(
                            backgroundColor: _estadoColor(v.estado),
                            child: const Icon(Icons.directions_walk,
                                color: Colors.white, size: 18),
                          ),
                          title: Text(v.tienda?.displayName ??
                              v.objetivo ??
                              'Visita #${v.id}'),
                          subtitle: Text(
                              '${v.fechaProgramada ?? '—'} · ${v.estado}'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _showDetalle(v),
                        );
                      },
                    ),
    );
  }
}