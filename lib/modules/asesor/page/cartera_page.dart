import 'package:flutter/material.dart';
import 'package:surti_nova/modules/asesor/models/tienda_model.dart';
import 'package:surti_nova/modules/asesor/services/asesor_service.dart';
class CarteraPage extends StatefulWidget {
  const CarteraPage({super.key});
 
  @override
  State<CarteraPage> createState() => _CarteraPageState();
}
 
class _CarteraPageState extends State<CarteraPage> {
  final _svc = AsesorService.instance;
  List<TiendaModel> _tiendas = [];
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
      _tiendas = await _svc.getCartera();
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() => _loading = false);
    }
  }
 
  void _snack(String msg, {bool error = false}) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red : Colors.green,
      ));
 
  // ── Formulario prospecto ─────────────────────────────────
  void _formProspecto() {
    final nombreEstCtrl  = TextEditingController();
    final nombrePropCtrl = TextEditingController();
    final telCtrl        = TextEditingController();
    final dirCtrl        = TextEditingController();
    final barrioCtrl     = TextEditingController();
    final ciudadCtrl     = TextEditingController();
    final obsCtrl        = TextEditingController();
 
    _showSheet(
      title: 'Registrar Prospecto',
      fields: [
        _field('nombre_establecimiento *', nombreEstCtrl),
        _field('nombre_propietario *', nombrePropCtrl),
        _field('telefono *', telCtrl, type: TextInputType.phone),
        _field('direccion *', dirCtrl),
        _field('barrio', barrioCtrl),
        _field('ciudad *', ciudadCtrl),
        _field('observaciones', obsCtrl, maxLines: 2),
      ],
      onGuardar: () async {
        await _svc.registrarProspecto({
          'nombre_establecimiento': nombreEstCtrl.text,
          'nombre_propietario':     nombrePropCtrl.text,
          'telefono':               telCtrl.text,
          'direccion':              dirCtrl.text,
          'barrio':                 barrioCtrl.text.isEmpty ? null : barrioCtrl.text,
          'ciudad':                 ciudadCtrl.text,
          'observaciones':          obsCtrl.text.isEmpty ? null : obsCtrl.text,
        });
      },
    );
  }
 
  // ── Formulario tienda formal ─────────────────────────────
  void _formTienda() {
    final razonCtrl  = TextEditingController();
    final nitCtrl    = TextEditingController();
    final propCtrl   = TextEditingController();
    final telCtrl    = TextEditingController();
    final emailCtrl  = TextEditingController();
    final dirCtrl    = TextEditingController();
 
    _showSheet(
      title: 'Registrar Tienda',
      fields: [
        _field('razon_social *', razonCtrl),
        _field('nit *', nitCtrl),
        _field('propietario *', propCtrl),
        _field('telefono *', telCtrl, type: TextInputType.phone),
        _field('email *', emailCtrl, type: TextInputType.emailAddress),
        _field('direccion *', dirCtrl),
      ],
      onGuardar: () async {
        await _svc.crearTienda({
          'razon_social': razonCtrl.text,
          'nit':          nitCtrl.text,
          'propietario':  propCtrl.text,
          'telefono':     telCtrl.text,
          'email':        emailCtrl.text,
          'direccion':    dirCtrl.text,
        });
      },
    );
  }
 
  // ── Formulario editar tienda ─────────────────────────────
  void _formEditar(TiendaModel t) {
    final razonCtrl  = TextEditingController(text: t.razonSocial);
    final propCtrl   = TextEditingController(text: t.propietario);
    final telCtrl    = TextEditingController(text: t.telefono);
    final emailCtrl  = TextEditingController(text: t.email);
    final dirCtrl    = TextEditingController(text: t.direccion);
 
    _showSheet(
      title: 'Editar Tienda #${t.id}',
      fields: [
        _field('razon_social', razonCtrl),
        _field('propietario', propCtrl),
        _field('telefono', telCtrl, type: TextInputType.phone),
        _field('email', emailCtrl, type: TextInputType.emailAddress),
        _field('direccion', dirCtrl),
      ],
      onGuardar: () async {
        await _svc.updateTienda(t.id, {
          if (razonCtrl.text.isNotEmpty)  'razon_social': razonCtrl.text,
          if (propCtrl.text.isNotEmpty)   'propietario':  propCtrl.text,
          if (telCtrl.text.isNotEmpty)    'telefono':     telCtrl.text,
          if (emailCtrl.text.isNotEmpty)  'email':        emailCtrl.text,
          if (dirCtrl.text.isNotEmpty)    'direccion':    dirCtrl.text,
        });
      },
    );
  }
 
  // ── Detalle tienda ───────────────────────────────────────
  void _detalle(TiendaModel t) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.displayName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            _detRow('Propietario', t.displayPropietario),
            _detRow('Teléfono', t.telefono),
            _detRow('Email', t.email),
            _detRow('Dirección', t.direccion),
            _detRow('Ciudad', t.ciudad),
            _detRow('Estado', t.estado),
            _detRow('NIT', t.nit),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('Editar'),
              onPressed: () {
                Navigator.pop(context);
                _formEditar(t);
              },
            ),
          ],
        ),
      ),
    );
  }
 
  // ── Helpers UI ───────────────────────────────────────────
  Widget _detRow(String label, String? value) => value == null
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(children: [
            Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
            Expanded(child: Text(value)),
          ]),
        );
 
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
 
  void _showSheet({
    required String title,
    required List<Widget> fields,
    required Future<void> Function() onGuardar,
  }) {
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
              Text(title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...fields,
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await onGuardar();
                    _snack('✓ Guardado correctamente');
                    _load();
                  } catch (e) {
                    _snack('✗ $e', error: true);
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
 
  Color _estadoColor(String? estado) {
    switch (estado) {
      case 'prospecto':   return Colors.orange;
      case 'registrada':  return Colors.blue;
      case 'en_prueba':   return Colors.purple;
      case 'activa':      return Colors.green;
      case 'inactiva':    return Colors.red;
      default:            return Colors.grey;
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Cartera'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'prospecto',
            icon: const Icon(Icons.person_add),
            label: const Text('Prospecto'),
            onPressed: _formProspecto,
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            heroTag: 'tienda',
            icon: const Icon(Icons.store),
            label: const Text('Tienda'),
            onPressed: _formTienda,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(_error!, style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: _load, child: const Text('Reintentar')),
                ]))
              : _tiendas.isEmpty
                  ? const Center(child: Text('Sin tiendas en cartera'))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
                      itemCount: _tiendas.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 4),
                      itemBuilder: (_, i) {
                        final t = _tiendas[i];
                        return ListTile(
                          tileColor: Colors.grey.shade100,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          leading: CircleAvatar(
                            backgroundColor: _estadoColor(t.estado),
                            child: const Icon(Icons.store, color: Colors.white, size: 18),
                          ),
                          title: Text(t.displayName),
                          subtitle: Text(
                              '${t.displayPropietario} · ${t.estado ?? '—'}'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _detalle(t),
                        );
                      },
                    ),
    );
  }
}