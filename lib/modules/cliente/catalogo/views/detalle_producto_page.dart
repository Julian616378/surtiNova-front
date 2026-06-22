import 'package:flutter/material.dart';
import '../models/producto.dart';

class DetalleProductoPage extends StatelessWidget {
  final Producto producto;

  const DetalleProductoPage({
    super.key,
    required this.producto,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(producto.nombre),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.inventory_2,
                size: 100,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              producto.nombre,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              producto.descripcion,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Precio: \$${producto.precio.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(
                  Icons.shopping_cart,
                ),
                label: const Text(
                  'Agregar al carrito',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}