import 'package:flutter/material.dart';
import 'package:surti_nova/core/theme/app_theme.dart'; // ajusta la ruta a donde pongas app_theme.dart
import 'package:surti_nova/modules/asesor/models/tienda_model.dart';
import 'package:surti_nova/modules/asesor/services/asesor_service.dart';
import 'package:dio/dio.dart';

/// Vista de cartera: ahora es solo consulta y edición de tiendas que ya
/// pasaron por el flujo de visita (CarteraPage ya no crea tiendas ni
/// prospectos — eso ocurre exclusivamente desde VisitarPage cuando el
/// asesor registra el resultado de una visita).
class CarteraPage extends StatefulWidget {
  const CarteraPage({super.key});

  @override
  State<CarteraPage> createState() => _CarteraPageState();
}

class _CarteraPageState extends State<CarteraPage> {
  final _svc = AsesorService.instance;

  List<TiendaModel> _tiendas    = [];
  List<TiendaModel> _filtradas  = [];
  bool _loading  = false;
  String? _error;

  // filtros
  String  _filtroEstado = 'todos';
  String  _orden        = 'recientes';
  String  _busqueda     = '';

  final _filtros = ['todos', 'prospecto', 'registrada', 'en_prueba', 'activa', 'inactiva'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      _tiendas = await _svc.getCartera();
      _aplicarFiltros();
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() => _loading = false);
    }
  }

  void _aplicarFiltros() {
    var lista = List<TiendaModel>.from(_tiendas);

    if (_filtroEstado != 'todos') {
      lista = lista.where((t) => t.estado == _filtroEstado).toList();
    }
    if (_busqueda.isNotEmpty) {
      final q = _busqueda.toLowerCase();
      lista = lista.where((t) =>
        (t.nombre?.toLowerCase().contains(q) ?? false) ||
        (t.propietario?.toLowerCase().contains(q) ?? false),
      ).toList();
    }

    switch (_orden) {
      case 'antiguos':
        lista = lista.reversed.toList();
        break;
      case 'az':
        lista.sort((a, b) => (a.nombre ?? '').compareTo(b.nombre ?? ''));
        break;
      case 'za':
        lista.sort((a, b) => (b.nombre ?? '').compareTo(a.nombre ?? ''));
        break;
    }

    setState(() => _filtradas = lista);
  }

  void _snack(String msg, {bool error = false, bool warn = false}) {
    Color bg = error ? AppColors.inactiva
             : warn  ? AppColors.prospecto
             : AppColors.activa;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(error ? Icons.error_outline : warn ? Icons.info_outline : Icons.check_circle_outline,
            color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Text(msg, style: const TextStyle(color: Colors.white)),
      ]),
      backgroundColor: bg,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // ── Filtros bottom sheet ─────────────────────────────────
  void _showFiltros() {
    String tmpEstado = _filtroEstado;
    String tmpOrden  = _orden;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setLocal) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              )),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Filtrar', style: AppTextStyles.heading),
                TextButton(
                  onPressed: () => setLocal(() { tmpEstado = 'todos'; tmpOrden = 'recientes'; }),
                  child: Text('Restablecer', style: TextStyle(color: AppColors.primary)),
                ),
              ]),
              const SizedBox(height: 8),
              const Text('Estado', style: AppTextStyles.label),
              const SizedBox(height: 8),
              ..._filtros.map((e) => _filtroRadio(e, tmpEstado, (v) => setLocal(() => tmpEstado = v!))),
              const Divider(height: 24),
              const Text('Ordenar por', style: AppTextStyles.label),
              const SizedBox(height: 8),
              ...['recientes', 'antiguos', 'az', 'za'].map((o) {
                final labels = {
                  'recientes': 'Más recientes',
                  'antiguos':  'Más antiguos',
                  'az':        'Nombre (A - Z)',
                  'za':        'Nombre (Z - A)',
                };
                return RadioListTile<String>(
                  dense: true,
                  title: Text(labels[o]!, style: AppTextStyles.body),
                  value: o,
                  groupValue: tmpOrden,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setLocal(() => tmpOrden = v!),
                );
              }),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() { _filtroEstado = tmpEstado; _orden = tmpOrden; });
                  _aplicarFiltros();
                },
                child: const Text('Aplicar filtros'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filtroRadio(String estado, String selected, ValueChanged<String?> onChanged) {
    final labels = {
      'todos': 'Todos', 'prospecto': 'Prospecto', 'registrada': 'Registrada',
      'en_prueba': 'En prueba', 'activa': 'Activa', 'inactiva': 'Inactiva',
    };
    final color = estado == 'todos' ? AppColors.primary : estadoColor(estado);
    final isSelected = estado == selected;

    return GestureDetector(
      onTap: () => onChanged(estado),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          border: Border.all(color: isSelected ? color : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(children: [
          Icon(_iconEstado(estado), color: color, size: 18),
          const SizedBox(width: 10),
          Text(labels[estado]!, style: AppTextStyles.body),
          const Spacer(),
          if (isSelected) Icon(Icons.check_circle, color: color, size: 18),
        ]),
      ),
    );
  }

  IconData _iconEstado(String estado) {
    switch (estado) {
      case 'todos':      return Icons.apps;
      case 'prospecto':  return Icons.person_outline;
      case 'registrada': return Icons.store;
      case 'en_prueba':  return Icons.science_outlined;
      case 'activa':     return Icons.check_circle_outline;
      case 'inactiva':   return Icons.cancel_outlined;
      default:           return Icons.store;
    }
  }

  // ── Formulario editar (única edición permitida en esta vista) ───
  void _formEditar(TiendaModel t) {
  final nombreCtrl = TextEditingController(text: t.nombre);
  final propCtrl   = TextEditingController(text: t.propietario);
  final telCtrl    = TextEditingController(text: t.telefono);
  final correoCtrl = TextEditingController(text: t.correo);
  final dirCtrl    = TextEditingController(text: t.direccion);
  String estadoSel = t.estado; // ✅ estado actual como valor inicial

  final estados = ['prospecto', 'registrada', 'en_prueba', 'activa', 'inactiva'];
  final estadoLabels = {
    'prospecto':  'Prospecto',
    'registrada': 'Registrada',
    'en_prueba':  'En prueba',
    'activa':     'Activa',
    'inactiva':   'Inactiva',
  };

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => StatefulBuilder(
      builder: (ctx, setLocal) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              )),
              const SizedBox(height: 16),
              const Text('Editar Tienda', style: AppTextStyles.heading),
              const SizedBox(height: 20),
              _field('Nombre', nombreCtrl),
              _field('Propietario', propCtrl),
              _field('Teléfono', telCtrl, type: TextInputType.phone),
              _field('Correo', correoCtrl, type: TextInputType.emailAddress),
              _field('Dirección', dirCtrl),
              // ✅ Selector de estado
              const Text('Estado', style: AppTextStyles.label),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: estados.map((e) {
                  final selected = estadoSel == e;
                  final color = estadoColor(e);
                  return GestureDetector(
                    onTap: () => setLocal(() => estadoSel = e),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? color : Colors.white,
                        border: Border.all(color: selected ? color : Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        estadoLabels[e]!,
                        style: TextStyle(
                          color: selected ? Colors.white : AppColors.onSurface,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    final Map<String, dynamic> data = {};
                    if (nombreCtrl.text.isNotEmpty) data['nombre']      = nombreCtrl.text;
                    if (propCtrl.text.isNotEmpty)   data['propietario'] = propCtrl.text;
                    if (telCtrl.text.isNotEmpty)    data['telefono']    = telCtrl.text;
                    if (correoCtrl.text.isNotEmpty) data['correo']      = correoCtrl.text;
                    if (dirCtrl.text.isNotEmpty)    data['direccion']   = dirCtrl.text;
                    data['estado'] = estadoSel; // ✅ siempre se manda
                    await _svc.updateTienda(t.id, data);
                    _snack('Tienda actualizada');
                    _load();
                  } catch (e) {
                    if (e is DioException) {
                      debugPrint('STATUS: ${e.response?.statusCode}');
                      debugPrint('BODY: ${e.response?.data}');
                    }
                    _snack('Error al guardar', error: true);
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
  // ── Detalle tienda ───────────────────────────────────────
  void _detalle(TiendaModel t) {
    final color = estadoColor(t.estado);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            )),
            const SizedBox(height: 20),
            Row(children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: color.withOpacity(0.15),
                child: Icon(Icons.store, color: color, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.displayName, style: AppTextStyles.heading),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(estadoLabel(t.estado),
                        style: TextStyle(color: color, fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              )),
            ]),
            const SizedBox(height: 16),
            const Divider(),
            _detRow(Icons.person_outline, 'Propietario', t.displayPropietario),
            _detRow(Icons.phone_outlined, 'Teléfono', t.telefono),
            _detRow(Icons.mail_outline, 'Correo', t.correo),
            _detRow(Icons.location_on_outlined, 'Dirección', t.direccion),
            _detRow(Icons.circle, 'Estado', estadoLabel(t.estado), dotColor: color),
            _detRow(Icons.badge_outlined, 'NIT', t.nit),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Editar Tienda'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
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
  Widget _detRow(IconData icon, String label, String? value, {Color? dotColor}) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Icon(icon, size: 18, color: dotColor ?? AppColors.subtle),
        const SizedBox(width: 12),
        Text('$label  ', style: AppTextStyles.caption),
        Expanded(child: Text(value, style: AppTextStyles.body, textAlign: TextAlign.end)),
      ]),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {
    String? hint,
    TextInputType type = TextInputType.text,
    IconData? suffix,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: TextField(
          controller: ctrl,
          keyboardType: type,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            suffixIcon: suffix != null ? Icon(suffix, color: AppColors.subtle) : null,
          ),
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
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              )),
              const SizedBox(height: 16),
              Text(title, style: AppTextStyles.heading),
              const SizedBox(height: 20),
              ...fields,
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await onGuardar();
                    _snack('Guardado correctamente');
                    _load();
                  } catch (e) {
                    if (e is DioException) {
                      debugPrint("STATUS: ${e.response?.statusCode}");
                      debugPrint("BODY: ${e.response?.data}");
                    } else {
                      debugPrint(e.toString());
                    }
                    _snack('Error al guardar', error: true);
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

  // ── Build ────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Header naranja ──────────────────────────────
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            backgroundColor: AppColors.primary,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _load,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                color: AppColors.primary,
                padding: const EdgeInsets.fromLTRB(20, 56, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    Text('Mi cartera 📋',
                        style: TextStyle(color: Colors.white, fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 2),
                    Text('Tiendas que ya visitaste',
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),

          // ── Buscador ────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar tienda o propietario...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.subtle),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (v) {
                      _busqueda = v;
                      _aplicarFiltros();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _showFiltros,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(children: [
                      const Icon(Icons.tune, size: 18, color: AppColors.subtle),
                      const SizedBox(width: 6),
                      Text('Filtrar', style: TextStyle(color: AppColors.subtle, fontSize: 13)),
                    ]),
                  ),
                ),
              ]),
            ),
          ),

          // ── Chips de estado ──────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 72,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                children: _filtros.map((e) {
                  final isAll     = e == 'todos';
                  final selected  = _filtroEstado == e;
                  final color     = isAll ? AppColors.primary : estadoColor(e);
                  final labels    = {
                    'todos': 'Todos', 'prospecto': 'Prospecto',
                    'registrada': 'Registrada', 'en_prueba': 'En prueba',
                    'activa': 'Activa', 'inactiva': 'Inactiva',
                  };
                  return GestureDetector(
                    onTap: () {
                      setState(() => _filtroEstado = e);
                      _aplicarFiltros();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? color : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: selected ? color : Colors.grey.shade200),
                      ),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(_iconEstado(e),
                            size: 18,
                            color: selected ? Colors.white : color),
                        const SizedBox(height: 2),
                        Text(labels[e]!,
                            style: TextStyle(
                              fontSize: 11,
                              color: selected ? Colors.white : AppColors.onSurface,
                              fontWeight: FontWeight.w500,
                            )),
                      ]),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ── Contador + ordenar ───────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${_filtradas.length} tiendas', style: AppTextStyles.caption),
                  GestureDetector(
                    onTap: _showFiltros,
                    child: Row(children: [
                      Text('Ordenar', style: TextStyle(fontSize: 13, color: AppColors.subtle)),
                      const Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.subtle),
                    ]),
                  ),
                ],
              ),
            ),
          ),

          // ── Lista / estados ──────────────────────────────
          if (_loading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            )
          else if (_error != null)
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.cloud_off_outlined, size: 56, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    const Text('Error al cargar',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    const Text('No se pudo obtener la información',
                        style: AppTextStyles.caption, textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    ElevatedButton(onPressed: _load, child: const Text('Reintentar')),
                  ]),
                ),
              ),
            )
          else if (_filtradas.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.store_mall_directory_outlined,
                      size: 56, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text('Sin tiendas en cartera',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  const Text('Las tiendas aparecen aquí después de registrarlas\ndesde una visita',
                      style: AppTextStyles.caption, textAlign: TextAlign.center),
                ]),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    final t = _filtradas[i];
                    final color = estadoColor(t.estado);
                    return GestureDetector(
                      onTap: () => _detalle(t),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: color.withOpacity(0.15),
                            child: Icon(Icons.store, color: color, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Expanded(
                                  child: Text(t.displayName,
                                      style: AppTextStyles.label,
                                      overflow: TextOverflow.ellipsis),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(estadoLabel(t.estado),
                                      style: TextStyle(color: color, fontSize: 11,
                                          fontWeight: FontWeight.w600)),
                                ),
                              ]),
                              const SizedBox(height: 4),
                              Text(t.displayPropietario ?? '—',
                                  style: AppTextStyles.caption),
                              const SizedBox(height: 2),
                              Row(children: [
                                Text(t.telefono ?? '—', style: AppTextStyles.caption),
                                const Text('  ·  ', style: AppTextStyles.caption),
                                Expanded(
                                  child: Text(t.direccion ?? '—',
                                      style: AppTextStyles.caption,
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ]),
                            ],
                          )),
                          const Icon(Icons.chevron_right,
                              color: AppColors.subtle, size: 20),
                        ]),
                      ),
                    );
                  },
                  childCount: _filtradas.length,
                ),
              ),
            ),
        ],
      ),
      // Sin floatingActionButton: esta vista ya no crea tiendas ni
      // prospectos. El registro nace siempre desde VisitarPage.
    );
  }
}