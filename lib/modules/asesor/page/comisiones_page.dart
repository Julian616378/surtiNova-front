import 'package:flutter/material.dart';
import 'package:surti_nova/modules/asesor/models/comision_model.dart';
import 'package:surti_nova/modules/asesor/services/asesor_service.dart';

class ComisionesPage extends StatefulWidget {
  const ComisionesPage({super.key});

  @override
  State<ComisionesPage> createState() => _ComisionesPageState();
}

class _ComisionesPageState extends State<ComisionesPage> {
  final _svc = AsesorService.instance;
  ComisionesResponse? _response;
List<ComisionModel> get _comisiones => _response?.comisiones ?? [];
double get _total => _comisiones.fold(0, (s, c) => s + (c.monto ?? 0));
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
      _response = await _svc.getMisComisiones();
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Comisiones'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                  ElevatedButton(onPressed: _load, child: const Text('Reintentar')),
                ]))
              : Column(
                  children: [
                    // Resumen total
                    Container(
                      width: double.infinity,
                      color: Colors.indigo.shade50,
                      padding: const EdgeInsets.all(16),
                      child: Column(children: [
                        const Text('Total', style: TextStyle(color: Colors.grey)),
                        Text(
                          '\$${_total.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo),
                        ),
                      ]),
                    ),
                    Expanded(
                      child: _comisiones.isEmpty
                          ? const Center(child: Text('Sin comisiones registradas'))
                          : ListView.separated(
                              padding: const EdgeInsets.all(12),
                              itemCount: _comisiones.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 4),
                              itemBuilder: (_, i) {
                                final c = _comisiones[i];
                                return ListTile(
                                  tileColor: Colors.grey.shade100,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  leading: const Icon(Icons.attach_money),
                                  title: Text(c.concepto ?? 'Comisión #${c.id}'),
                                  subtitle: Text(
                                      '${c.periodo ?? '—'} · ${c.estado ?? '—'}'),
                                  trailing: Text(
                                    '\$${c.monto?.toStringAsFixed(2) ?? '—'}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}