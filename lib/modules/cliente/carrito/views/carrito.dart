import 'package:flutter/material.dart';

import '../controllers/carrito_controller.dart';
import '../../pedidos/services/pedido_service.dart';

class CarritoPage extends StatefulWidget {
  const CarritoPage({super.key});

  @override
  State<CarritoPage> createState() => _CarritoPageState();
}

class _CarritoPageState extends State<CarritoPage> {
  Future<void> realizarPedido() async {
    try {
      final items = CarritoController.items
          .map(
            (item) => {
              "id_producto": item.producto.id,
              "cantidad": item.cantidad,
            },
          )
          .toList();

      await PedidoService().crearPedido(
        idTienda: 1,
        items: items,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pedido realizado correctamente',
          ),
        ),
      );

      setState(() {
        CarritoController.items.clear();
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al realizar pedido: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = CarritoController.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito'),
      ),
      body: items.isEmpty
          ? const Center(
              child: Text(
                'Tu carrito está vacío',
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];

                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          title: Text(
                            item.producto.nombre,
                          ),
                          subtitle: Text(
                            'Cantidad: ${item.cantidad}',
                          ),
                          trailing: Text(
                            '\$${item.subtotal.toStringAsFixed(0)}',
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Total: \$${CarritoController.total.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: realizarPedido,
                          icon: const Icon(
                            Icons.shopping_bag,
                          ),
                          label: const Text(
                            'Realizar Pedido',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}