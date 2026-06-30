import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/producto_controller.dart';
import '../../catalogo/controllers/catalogo_controller.dart';
import '../../catalogo/models/producto_model.dart';
import '../../shared/theme/app_theme.dart';

class ProductoDetalleView extends StatefulWidget {
  final int                productoId;
  final String             token;
  final CatalogoController ctrl;

  const ProductoDetalleView({super.key, required this.productoId, required this.token, required this.ctrl});

  @override
  State<ProductoDetalleView> createState() => _ProductoDetalleViewState();
}

class _ProductoDetalleViewState extends State<ProductoDetalleView> {
  late ProductoController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = ProductoController();
    _ctrl.init(widget.token, widget.productoId, widget.ctrl.productos);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _ctrl,
      child: Consumer<ProductoController>(
        builder: (_, ctrl, __) {
          if (ctrl.cargando) return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppTheme.primary)));
          if (ctrl.error != null) return Scaffold(body: Center(child: Text(ctrl.error!)));
          final p = ctrl.producto!;

          return Scaffold(
            backgroundColor: Colors.white,
            body: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImageHeader(ctrl, p),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.nombre, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: AppTheme.stockGreen.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                              child: Text(p.enStock ? 'En stock' : 'Sin stock',
                                style: TextStyle(color: p.enStock ? AppTheme.stockGreen : Colors.red, fontSize: 12, fontWeight: FontWeight.w600)),
                            ),
                            const SizedBox(height: 10),
                            Text('\$${p.precio.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.priceOrange)),
                            const SizedBox(height: 6),
                            Text(p.descripcion ?? 'Sin descripción.', style: const TextStyle(fontSize: 14, color: AppTheme.textGrey)),
                            const SizedBox(height: 20),
                            _buildAtributos(p),
                            const SizedBox(height: 24),
                            _buildCantidad(ctrl),
                            const SizedBox(height: 28),
                            _buildRelacionados(ctrl),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildBotonAgregar(ctrl, p),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageHeader(ProductoController ctrl, ProductoModel p) {
    return Container(
      height: 280,
      color: const Color(0xFFF8F8F8),
      child: Stack(
        children: [
          Center(
            child: p.imagen != null
              ? Image.network(p.imagen!, height: 220, fit: BoxFit.contain,
                  errorBuilder: (_,__,___) => const Icon(Icons.image, size: 80, color: Colors.grey))
              : const Icon(Icons.image, size: 80, color: Colors.grey),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6)]),
                      child: const Icon(Icons.close, size: 20, color: AppTheme.textDark),
                    ),
                  ),
                  GestureDetector(
                    onTap: ctrl.toggleFavorito,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6)]),
                      child: Icon(ctrl.favorito ? Icons.favorite : Icons.favorite_border,
                        size: 20, color: ctrl.favorito ? Colors.red : AppTheme.textGrey),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAtributos(ProductoModel p) {
    return Row(
      children: [
        _atributo(Icons.water_drop_outlined, '${p.contenido} ${p.unidadMedida ?? 'ml'}', 'Contenido', const Color(0xFF2196F3)),
        const SizedBox(width: 12),
        _atributo(Icons.eco_outlined, p.tieneAzucar ? 'Con azúcar' : 'Sin azúcar', 'Natural', const Color(0xFF4CAF50)),
        const SizedBox(width: 12),
        _atributo(Icons.inventory_2_outlined, '${p.piezasPorCaja} pz', 'Por caja', const Color(0xFF9C27B0)),
      ],
    );
  }

  Widget _atributo(IconData icon, String valor, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: color.withOpacity(0.07), borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(valor, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textGrey)),
        ]),
      ),
    );
  }

  Widget _buildCantidad(ProductoController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Cantidad', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        const SizedBox(height: 12),
        Row(
          children: [
            _btnCantidad(Icons.remove, ctrl.decrementar),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text('${ctrl.cantidad}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
            ),
            _btnCantidad(Icons.add, ctrl.incrementar),
            const Spacer(),
            const Text('Máximo 20 piezas\npor pedido', style: TextStyle(fontSize: 11, color: AppTheme.textGrey)),
          ],
        ),
      ],
    );
  }

  Widget _btnCantidad(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 18, color: AppTheme.textDark),
      ),
    );
  }

  Widget _buildRelacionados(ProductoController ctrl) {
    if (ctrl.relacionados.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('También te puede interesar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        const SizedBox(height: 14),
        Row(
          children: ctrl.relacionados.map((r) => Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (_) => ProductoDetalleView(productoId: r.id, token: widget.token, ctrl: widget.ctrl),
              )),
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: r.imagen != null
                        ? Image.network(r.imagen!, height: 70, fit: BoxFit.cover,
                            errorBuilder: (_,__,___) => Container(height: 70, color: const Color(0xFFF0F0F0),
                              child: const Icon(Icons.image, color: Colors.grey)))
                        : Container(height: 70, color: const Color(0xFFF0F0F0),
                            child: const Icon(Icons.image, color: Colors.grey)),
                    ),
                    const SizedBox(height: 6),
                    Text(r.nombre, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppTheme.textDark),
                      textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                    Text('\$${r.precio.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.priceOrange)),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => widget.ctrl.agregarAlCarrito(r.id),
                      child: Container(
                        width: 28, height: 28,
                        decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                        child: const Icon(Icons.add, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildBotonAgregar(ProductoController ctrl, ProductoModel p) {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: p.enStock ? () {
                  for (int i = 0; i < ctrl.cantidad; i++) widget.ctrl.agregarAlCarrito(p.id);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Producto agregado al carrito'),
                    backgroundColor: AppTheme.primary,
                    duration: Duration(seconds: 2),
                  ));
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Text('Agregar al carrito  \$${(p.precio * ctrl.cantidad).toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ]),
              ),
            ),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
              Icon(Icons.lock_outline, size: 14, color: AppTheme.stockGreen),
              SizedBox(width: 4),
              Text('Compra 100% segura', style: TextStyle(fontSize: 12, color: AppTheme.stockGreen, fontWeight: FontWeight.w500)),
            ]),
          ],
        ),
      ),
    );
  }
}