import 'package:flutter/material.dart';

import '../../carrito/views/carrito.dart';
import '../controllers/catalogo_controller.dart';
import '../models/producto.dart';
import '../widgets/producto_card.dart';

class CatalogoPage extends StatefulWidget {
  const CatalogoPage({super.key});

  @override
  State<CatalogoPage> createState() => _CatalogoPageState();
}

class _CatalogoPageState extends State<CatalogoPage> {
  final CatalogoController _controller = CatalogoController();
  final TextEditingController _buscarController =
      TextEditingController();

  List<Producto> productos = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarProductos();
  }

  @override
  void dispose() {
    _buscarController.dispose();
    super.dispose();
  }

  Future<void> cargarProductos({
    String buscar = '',
  }) async {
    if (mounted) {
      setState(() {
        cargando = true;
      });
    }

    try {
      final lista = await _controller.obtenerProductos(
        buscar: buscar,
      );

      if (mounted) {
        setState(() {
          productos = lista;
          cargando = false;
        });
      }
    } catch (e) {
      debugPrint(e.toString());

      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

  void abrirCarrito() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CarritoPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Catálogo"),
        actions: [
          IconButton(
            onPressed: abrirCarrito,
            icon: const Icon(Icons.shopping_cart),
            tooltip: "Carrito",
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _buscarController,
              onChanged: (value) {
                cargarProductos(
                  buscar: value,
                );
              },
              decoration: InputDecoration(
                hintText: "Buscar producto...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _buscarController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _buscarController.clear();
                          cargarProductos();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),

          Expanded(
            child: cargando
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : productos.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 70,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 10),
                            Text(
                              "No se encontraron productos",
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => cargarProductos(
                          buscar: _buscarController.text,
                        ),
                        child: ListView.builder(
                          padding: const EdgeInsets.only(
                            bottom: 80,
                          ),
                          itemCount: productos.length,
                          itemBuilder: (context, index) {
                            return ProductoCard(
                              producto: productos[index],
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: abrirCarrito,
        icon: const Icon(Icons.shopping_cart),
        label: const Text("Carrito"),
      ),
    );
  }
}