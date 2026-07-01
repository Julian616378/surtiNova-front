import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../catalogo/controllers/catalogo_controller.dart';
import '../../catalogo/models/producto_model.dart';
import '../../shared/theme/app_theme.dart';
import '../controllers/pedido_controller.dart';

class CarritoView extends StatefulWidget {
  final String token;
  final int idTienda;
  final CatalogoController carritoCtrl;

  const CarritoView({super.key, required this.token, required this.idTienda, required this.carritoCtrl});

  @override
  State<CarritoView> createState() => _CarritoViewState();
}

class _CarritoViewState extends State<CarritoView> {
  final PedidoController _pedidoCtrl = PedidoController();

 Future<void> _confirmar() async {
    debugPrint('>>> idTienda recibido: ${widget.idTienda}');
    final pedido = await _pedidoCtrl.confirmarPedido(
      widget.token,
      widget.idTienda,
      widget.carritoCtrl,
    );

    if (!mounted) return;

    if (pedido != null) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 52),
            ),
            const SizedBox(height: 14),
            const Text('¡Pedido confirmado!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Pedido #${pedido.id}', style: const TextStyle(color: Color(0xFF9E9E9E))),
            const SizedBox(height: 4),
            Text('Total: \$${pedido.total.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary)),
          ]),
          actions: [
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  backgroundColor: AppTheme.primary.withOpacity(0.08),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Aceptar',
                  style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_pedidoCtrl.error ?? 'Error al confirmar pedido'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  void _eliminarProducto(CatalogoController catCtrl, int id) {
    catCtrl.carrito.remove(id);
    catCtrl.notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _pedidoCtrl,
      child: AnimatedBuilder(
        animation: widget.carritoCtrl,
        builder: (context, _) {
          return Consumer<PedidoController>(
        builder: (_, pedCtrl, __) {
          final catCtrl = widget.carritoCtrl;

          final List<({ProductoModel producto, int cantidad})> items = [];
          for (final entry in catCtrl.carrito.entries) {
            ProductoModel? producto;
            for (final p in catCtrl.productos) {
              if (p.id == entry.key) { producto = p; break; }
            }
            if (producto != null) {
              items.add((producto: producto, cantidad: entry.value));
            }
          }

          final total = items.fold<double>(0, (sum, i) => sum + (i.producto.precio * i.cantidad));
          final totalItems = items.fold<int>(0, (sum, i) => sum + i.cantidad);

          return Scaffold(
            backgroundColor: const Color(0xFFF7F7F9),
            appBar: AppBar(
              backgroundColor: AppTheme.primary,
              title: const Text('Mi Carrito',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              iconTheme: const IconThemeData(color: Colors.white),
              elevation: 0,
              actions: [
                if (catCtrl.carrito.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      catCtrl.carrito.clear();
                      catCtrl.notifyListeners();
                    },
                    icon: const Icon(Icons.delete_sweep_outlined, color: Colors.white70, size: 20),
                    label: const Text('Vaciar', style: TextStyle(color: Colors.white70)),
                  ),
              ],
            ),
            body: items.isEmpty
                ? Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      const Text('Tu carrito está vacío',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF616161))),
                      const SizedBox(height: 4),
                      const Text('Agrega productos para continuar',
                        style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E))),
                    ]),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          children: [
                            for (final item in items)
                              Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: item.producto.imagen != null
                                              ? Image.network(item.producto.imagen!,
                                                  width: 64, height: 64, fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) => _placeholder())
                                              : _placeholder(),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(item.producto.nombre,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5)),
                                              const SizedBox(height: 4),
                                              Text('\$${item.producto.precio.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  color: AppTheme.primary,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                )),
                                            ],
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () => _eliminarProducto(catCtrl, item.producto.id),
                                          borderRadius: BorderRadius.circular(8),
                                          child: const Padding(
                                            padding: EdgeInsets.all(4),
                                            child: Icon(Icons.delete_outline, color: Color(0xFFE53935), size: 22),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Subtotal: \$${(item.producto.precio * item.cantidad).toStringAsFixed(2)}',
                                          style: const TextStyle(fontSize: 12.5, color: Color(0xFF9E9E9E)),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF5F5F7),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              _btnCantidad(
                                                Icons.remove,
                                                () => catCtrl.quitarDelCarrito(item.producto.id),
                                              ),
                                              SizedBox(
                                                width: 36,
                                                child: Text(
                                                  '${item.cantidad}',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                              _btnCantidad(
                                                Icons.add,
                                                () => catCtrl.agregarAlCarrito(item.producto.id),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                          boxShadow: [
                            BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, -4)),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('$totalItems producto${totalItems == 1 ? '' : 's'}',
                                  style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 13.5)),
                                Text('\$${total.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                              ],
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: pedCtrl.enviando ? null : _confirmar,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 0,
                                ),
                                child: pedCtrl.enviando
                                    ? const SizedBox(
                                        width: 22, height: 22,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : const Text(
                                        'Confirmar Pedido',
                                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          );
        },
      );
        },
      ),
    );
  }

  Widget _placeholder() => Container(
        width: 64, height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.image_outlined, color: Colors.grey, size: 26),
      );

  Widget _btnCantidad(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 32, height: 32,
        alignment: Alignment.center,
        child: Icon(icon, size: 17, color: AppTheme.primary),
      ),
    );
  }
}