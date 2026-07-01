import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/catalogo_controller.dart';
import '../models/producto_model.dart';
import '../services/catalogo_service.dart';
import '../widgets/producto_card.dart';
import '../../shared/theme/app_theme.dart';
import '../widgets/carrito_fab.dart';
import '../../pedido/views/carrito_view.dart';

class CatalogoView extends StatefulWidget {
  final String token;
  final int idTienda;
  const CatalogoView({super.key, required this.token, required this.idTienda});

  @override
  State<CatalogoView> createState() => _CatalogoViewState();
}

class _CatalogoViewState extends State<CatalogoView> {
  late CatalogoController _ctrl;
  final _searchCtrl = TextEditingController();
  int _navIndex = 1;

  @override
  void initState() {
    super.initState();
    _ctrl = CatalogoController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ctrl.init(widget.token);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _abrirDetalle(int productoId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProductoSheet(
        productoId: productoId,
        token: widget.token,
        ctrl: _ctrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _ctrl,
      child: Consumer<CatalogoController>(
        builder: (_, ctrl, __) => Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          body: Column(
            children: [
              _buildHeader(ctrl),
              _buildCategorias(ctrl),
              _buildProductosHeader(ctrl),
              Expanded(child: _buildLista(ctrl)),
            ],
          ),
          floatingActionButton: CarritoFab(
            totalItems: ctrl.totalCarrito,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CarritoView(token: widget.token, idTienda: widget.idTienda, carritoCtrl: ctrl),
              ),
            ),
          ),
          bottomNavigationBar: _buildNavBar(),
        ),
      ),
    );
  }

  Widget _buildHeader(CatalogoController ctrl) {
    return Container(
      color: AppTheme.primary,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16, right: 16, bottom: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.menu, color: Colors.white, size: 26),
              Row(children: const [
                Icon(Icons.shopping_cart, color: Colors.white, size: 18),
                SizedBox(width: 6),
                Text.rich(TextSpan(children: [
                  TextSpan(text: 'Surti', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                  TextSpan(text: 'Nova', style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w300)),
                ])),
              ]),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 28),
                  if (ctrl.totalCarrito > 0)
                    Positioned(
                      top: -6, right: -6,
                      child: Container(
                        width: 18, height: 18,
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: Center(
                          child: Text('${ctrl.totalCarrito}',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Row(children: [
            Text('¡Hola, Cliente! ', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            Text('👋', style: TextStyle(fontSize: 20)),
          ]),
          const Text('Descubre nuestros productos', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => _ctrl.buscar(widget.token, v),
                  decoration: const InputDecoration(
                    hintText: 'Buscar producto...',
                    hintStyle: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: Color(0xFF9E9E9E), size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildCategorias(CatalogoController ctrl) {
    final iconos = <String, IconData>{
      'Lácteos':  Icons.water_drop_outlined,
      'Bebidas':  Icons.local_drink_outlined,
      'Snacks':   Icons.cookie_outlined,
      'Limpieza': Icons.cleaning_services_outlined,
    };

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _categoriaChip(null, Icons.grid_view_rounded, 'Todos', ctrl),
            ...ctrl.categorias.map((c) => _categoriaChip(
              c.id,
              iconos[c.nombre] ?? Icons.category_outlined,
              c.nombre,
              ctrl,
            )),
          ],
        ),
      ),
    );
  }

  Widget _categoriaChip(int? id, IconData icon, String label, CatalogoController ctrl) {
    final selected = ctrl.categoriaSeleccionada == id;
    return GestureDetector(
      onTap: () => ctrl.seleccionarCategoria(widget.token, id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary.withOpacity(0.1) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppTheme.primary : Colors.transparent, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: selected ? AppTheme.primary : const Color(0xFF9E9E9E)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500,
              color: selected ? AppTheme.primary : const Color(0xFF9E9E9E))),
          ],
        ),
      ),
    );
  }

  Widget _buildProductosHeader(CatalogoController ctrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Productos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
          Text('${ctrl.productosFiltrados.length} productos', style: const TextStyle(fontSize: 13, color: Color(0xFF9E9E9E))),
        ],
      ),
    );
  }

  Widget _buildLista(CatalogoController ctrl) {
    if (ctrl.cargando) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }
    if (ctrl.error != null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text(ctrl.error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => ctrl.init(widget.token),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            child: const Text('Reintentar', style: TextStyle(color: Colors.white)),
          ),
        ]),
      );
    }
    if (ctrl.productosFiltrados.isEmpty) {
      return const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.search_off, size: 48, color: Colors.grey),
          SizedBox(height: 8),
          Text('Sin productos', style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 15)),
        ]),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: ctrl.productosFiltrados.length,
      itemBuilder: (_, i) {
        final p = ctrl.productosFiltrados[i];
        return ProductoCard(
          producto: p,
          onTap: () => _abrirDetalle(p.id),
          onAgregar: () => _abrirDetalle(p.id),
        );
      },
    );
  }

  Widget _buildNavBar() {
    return BottomNavigationBar(
      currentIndex: _navIndex,
      onTap: (i) => setState(() => _navIndex = i),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.primary,
      unselectedItemColor: const Color(0xFF9E9E9E),
      selectedFontSize: 11,
      unselectedFontSize: 11,
      backgroundColor: Colors.white,
      elevation: 10,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined),         activeIcon: Icon(Icons.home),          label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined),    activeIcon: Icon(Icons.grid_view),     label: 'Catálogo'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite_outline),      activeIcon: Icon(Icons.favorite),      label: 'Favoritos'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long),  label: 'Pedidos'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline),        activeIcon: Icon(Icons.person),        label: 'Perfil'),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// BOTTOM SHEET — Detalle del producto
// ═══════════════════════════════════════════════════════════════════════════

class _ProductoSheet extends StatefulWidget {
  final int productoId;
  final String token;
  final CatalogoController ctrl;

  const _ProductoSheet({
    required this.productoId,
    required this.token,
    required this.ctrl,
  });

  @override
  State<_ProductoSheet> createState() => _ProductoSheetState();
}

class _ProductoSheetState extends State<_ProductoSheet> {
  late Future<ProductoModel?> _futureProducto;
  int _cantidad = 1;
  bool _favorito = false;

  @override
  void initState() {
    super.initState();
    _futureProducto = CatalogoService().getProductoDetalle(widget.token, widget.productoId);
  }

  // FIX: guarda el contexto del Navigator padre ANTES de hacer pop
  // para poder usarlo en el Future.delayed sin que el contexto esté desmontado.
  void _reabrirSheet(int productoId) {
    final nav = Navigator.of(context);
    final parentContext = context;
    nav.pop();
    Future.delayed(const Duration(milliseconds: 250), () {
      showModalBottomSheet(
        context: parentContext,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _ProductoSheet(
          productoId: productoId,
          token: widget.token,
          ctrl: widget.ctrl,
        ),
      );
    });
  }

@override
Widget build(BuildContext context) {
  return DraggableScrollableSheet(
    initialChildSize: 0.88,
    minChildSize: 0.5,
    maxChildSize: 0.95,
    expand: true,
    builder: (_, scrollCtrl) {
      return SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: FutureBuilder<ProductoModel?>(
            future: _futureProducto,
            builder: (_, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primary,
                  ),
                );
              }

              if (!snap.hasData || snap.data == null) {
                return const Center(
                  child: Text('No se pudo cargar el producto'),
                );
              }

              return _buildContenido(
                snap.data!,
                scrollCtrl,
              );
            },
          ),
        ),
      );
    },
  );
}

  Widget _buildContenido(ProductoModel p, ScrollController scrollCtrl) {
    final relacionados = widget.ctrl.productos
        .where((r) => r.id != p.id && r.categoriaId == p.categoriaId)
        .take(3)
        .toList();

    return Stack(
      children: [
        ListView(
          controller: scrollCtrl,
          padding: const EdgeInsets.only(bottom: 120),
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
              ),
            ),

            // Botones X y ❤️
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _iconBtn(Icons.close, const Color(0xFF1A1A1A), () => Navigator.pop(context)),
                  _iconBtn(
                    _favorito ? Icons.favorite : Icons.favorite_border,
                    _favorito ? Colors.red : const Color(0xFF9E9E9E),
                    () => setState(() => _favorito = !_favorito),
                  ),
                ],
              ),
            ),

            // Imagen + info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: p.imagen != null
                        ? Image.network(p.imagen!, width: 120, height: 120, fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => _placeholder())
                        : _placeholder(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.nombre,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            p.enStock ? 'En stock' : 'Sin stock',
                            style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w600,
                              color: p.enStock ? const Color(0xFF4CAF50) : Colors.red,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('\$${p.precio.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                        const SizedBox(height: 4),
                        Text(p.descripcion ?? '',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Atributos
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                _atributo(Icons.water_drop_outlined,
                  '${p.contenido} ${p.unidadMedida ?? 'ml'}', 'Contenido', const Color(0xFF2196F3)),
                const SizedBox(width: 10),
                _atributo(Icons.eco_outlined,
                  p.tieneAzucar ? 'Con azúcar' : 'Sin azúcar', 'Natural', const Color(0xFF4CAF50)),
                const SizedBox(width: 10),
                _atributo(Icons.inventory_2_outlined,
                  '${p.piezasPorCaja} pz', 'Por caja', const Color(0xFF9C27B0)),
              ]),
            ),

            const SizedBox(height: 24),

            // Cantidad
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Cantidad',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
                  const SizedBox(height: 12),
                  Row(children: [
                    _btnCantidad(Icons.remove, () { if (_cantidad > 1) setState(() => _cantidad--); }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text('$_cantidad',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
                    ),
                    _btnCantidad(Icons.add, () { if (_cantidad < 20) setState(() => _cantidad++); }),
                    const Spacer(),
                    const Text('Máximo 20 piezas\npor pedido',
                      style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)), textAlign: TextAlign.right),
                  ]),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Relacionados
            if (relacionados.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('También te puede interesar',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: relacionados.map((r) => Expanded(
                    child: GestureDetector(
                      onTap: () => _reabrirSheet(r.id),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: Column(children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: r.imagen != null
                                ? Image.network(r.imagen!, height: 65, fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _placeholder(w: 65, h: 65))
                                : _placeholder(w: 65, h: 65),
                          ),
                          const SizedBox(height: 4),
                          Text(r.nombre,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                          Text('\$${r.precio.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                          const SizedBox(height: 4),
                          // FIX: agrega al carrito sin usar context después de pop
                          GestureDetector(
                            onTap: () {
                              widget.ctrl.agregarAlCarrito(r.id);
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('${r.nombre} agregado'),
                                backgroundColor: AppTheme.primary,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                duration: const Duration(seconds: 1),
                              ));
                            },
                            child: Container(
                              width: 26, height: 26,
                              decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                              child: const Icon(Icons.add, color: Colors.white, size: 16),
                            ),
                          ),
                        ]),
                      ),
                    ),
                  )).toList(),
                ),
              ),
            ],
          ],
        ),

        // ── Botón fijo abajo ──────────────────────────────────────────────
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    // FIX: guarda messenger y nav ANTES del pop para no usar context desmontado
                    onPressed: p.enStock ? () {
                      final messenger = ScaffoldMessenger.of(context);
                      final nombre = p.nombre;
                      final precio = p.precio;
                      widget.ctrl.agregarAlCarrito(p.id, cantidad: _cantidad);
                      Navigator.pop(context);
                      messenger.showSnackBar(SnackBar(
                        content: Text('$nombre agregado al carrito'),
                        backgroundColor: AppTheme.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        duration: const Duration(seconds: 2),
                      ));
                    } : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        'Agregar al carrito   \$${(p.precio * _cantidad).toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ]),
                  ),
                ),
                const SizedBox(height: 8),
                const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.lock_outline, size: 13, color: Color(0xFF4CAF50)),
                  SizedBox(width: 4),
                  Text('Compra 100% segura',
                    style: TextStyle(fontSize: 12, color: Color(0xFF4CAF50), fontWeight: FontWeight.w500)),
                ]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(color: Color(0xFFF5F5F5), shape: BoxShape.circle),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }

  Widget _atributo(IconData icon, String valor, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withOpacity(0.07), borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 3),
          Text(valor, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF9E9E9E))),
        ]),
      ),
    );
  }

  Widget _btnCantidad(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF1A1A1A)),
      ),
    );
  }

  Widget _placeholder({double w = 120, double h = 120}) => Container(
        width: w, height: h, color: const Color(0xFFF0F0F0),
        child: const Icon(Icons.image, color: Colors.grey),
      );
}