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

    if (CarritoController.estaVacio) {
      return;
    }

    try {

      await PedidoService().crearPedido(
        idTienda: 1,
        items: CarritoController.itemsPedido,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Pedido realizado correctamente",
          ),
        ),
      );

      setState(() {
        CarritoController.vaciarCarrito();
      });

      Navigator.pop(context);

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error al realizar pedido: $e",
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
        title: const Text("Mi Pedido"),
        centerTitle: true,
      ),

      body: items.isEmpty

          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 90,
                    color: Colors.grey,
                  ),

                  SizedBox(height: 20),

                  Text(
                    "Tu carrito está vacío",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),

                ],
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

                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),

                        elevation: 3,

                        child: Padding(

                          padding: const EdgeInsets.all(15),

                          child: Column(

                            crossAxisAlignment:
                                CrossAxisAlignment.start,

                            children: [

                              Text(

                                item.producto.nombre,

                                style: const TextStyle(

                                  fontSize: 18,

                                  fontWeight:
                                      FontWeight.bold,

                                ),

                              ),

                              const SizedBox(height: 10),

                              Text(
                                "Precio unitario: \$${item.producto.precio.toStringAsFixed(0)}",
                              ),

                              const SizedBox(height: 15),

                              Row(

                                children: [

                                  IconButton(

                                    onPressed: () {

                                      setState(() {

                                        CarritoController
                                            .disminuirCantidad(
                                          item.producto.id,
                                        );

                                      });

                                    },

                                    icon: const Icon(
                                      Icons.remove_circle,
                                    ),

                                  ),

                                  Text(

                                    item.cantidad.toString(),

                                    style: const TextStyle(

                                      fontSize: 18,

                                      fontWeight:
                                          FontWeight.bold,

                                    ),

                                  ),

                                  IconButton(

                                    onPressed: () {

                                      setState(() {

                                        CarritoController
                                            .aumentarCantidad(
                                          item.producto.id,
                                        );

                                      });

                                    },

                                    icon: const Icon(
                                      Icons.add_circle,
                                    ),

                                  ),

                                  const Spacer(),

                                  IconButton(

                                    onPressed: () {

                                      setState(() {

                                        CarritoController
                                            .eliminarProducto(
                                          item.producto.id,
                                        );

                                      });

                                    },

                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),

                                  ),

                                ],

                              ),

                              const SizedBox(height: 10),

                              Align(

                                alignment:
                                    Alignment.centerRight,

                                child: Text(

                                  "Subtotal: \$${item.subtotal.toStringAsFixed(0)}",

                                  style: const TextStyle(

                                    fontWeight:
                                        FontWeight.bold,

                                    fontSize: 18,

                                  ),

                                ),

                              ),

                            ],

                          ),

                        ),

                      );

                    },

                  ),

                ),

                Container(

                  padding: const EdgeInsets.all(20),

                  decoration: const BoxDecoration(

                    color: Colors.white,

                    boxShadow: [

                      BoxShadow(
                        blurRadius: 8,
                        color: Colors.black12,
                      ),

                    ],

                  ),

                  child: Column(

                    children: [

                      Row(

                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,

                        children: [

                          const Text(
                            "Productos",
                          ),

                          Text(
                            CarritoController.totalProductos
                                .toString(),
                          ),

                        ],

                      ),

                      const SizedBox(height: 8),

                      Row(

                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,

                        children: [

                          const Text(
                            "Unidades",
                          ),

                          Text(
                            CarritoController.totalUnidades
                                .toString(),
                          ),

                        ],

                      ),

                      const Divider(),

                      Row(

                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,

                        children: [

                          const Text(

                            "TOTAL",

                            style: TextStyle(

                              fontWeight:
                                  FontWeight.bold,

                              fontSize: 22,

                            ),

                          ),

                          Text(

                            "\$${CarritoController.total.toStringAsFixed(0)}",

                            style: const TextStyle(

                              fontWeight:
                                  FontWeight.bold,

                              fontSize: 22,

                              color: Colors.green,

                            ),

                          ),

                        ],

                      ),

                      const SizedBox(height: 20),

                      SizedBox(

                        width: double.infinity,

                        child: ElevatedButton.icon(

                          onPressed: realizarPedido,

                          icon: const Icon(
                            Icons.shopping_bag,
                          ),

                          label: const Text(
                            "REALIZAR PEDIDO",
                          ),

                        ),

                      ),

                      const SizedBox(height: 10),

                      SizedBox(

                        width: double.infinity,

                        child: OutlinedButton.icon(

                          onPressed: () {

                            setState(() {

                              CarritoController
                                  .vaciarCarrito();

                            });

                          },

                          icon: const Icon(
                            Icons.delete_outline,
                          ),

                          label: const Text(
                            "VACIAR CARRITO",
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