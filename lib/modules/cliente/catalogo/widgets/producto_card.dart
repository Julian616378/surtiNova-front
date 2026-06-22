import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../views/detalle_producto_page.dart';
import '../../carrito/controllers/carrito_controller.dart';

class ProductoCard extends StatelessWidget {
  final Producto producto;

  const ProductoCard({
    super.key,
    required this.producto,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius:
                    BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.inventory_2,
                size: 70,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              producto.nombre,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              producto.descripcion,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 10),

            Text(
              '\$${producto.precio.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            DetalleProductoPage(
                          producto: producto,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.visibility),
                  tooltip: 'Ver detalle',
                ),

                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.favorite_border,
                  ),
                  tooltip: 'Favorito',
                ),

                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.share),
                  tooltip: 'Compartir',
                ),

                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.local_offer,
                  ),
                  tooltip: 'Oferta',
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      CarritoController
                          .agregarProducto(
                        producto,
                      );

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${producto.nombre} agregado al carrito',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.shopping_cart,
                    ),
                    label: const Text(
                      'Agregar',
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      CarritoController
                          .agregarProducto(
                        producto,
                      );

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Producto agregado. Ve al carrito para finalizar el pedido.',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.flash_on,
                    ),
                    label: const Text(
                      'Comprar',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}