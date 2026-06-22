import 'package:flutter/material.dart';

import '../controllers/catalogo_controller.dart';
import '../models/producto.dart';
import '../widgets/producto_card.dart';
import '../../carrito/views/carrito.dart';

class CatalogoPage extends StatefulWidget {
  const CatalogoPage({super.key});

  @override
  State<CatalogoPage> createState() => _CatalogoPageState();
}

class _CatalogoPageState extends State<CatalogoPage> {
  final CatalogoController _controller = CatalogoController();

  List<Producto> productos = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarProductos();
  }

  Future<void> cargarProductos() async {
    try {
      final lista = await _controller.obtenerProductos();

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
        title: const Text('Catálogo'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
            tooltip: 'Buscar',
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtrar',
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.sort),
            tooltip: 'Ordenar',
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.local_offer),
            tooltip: 'Ofertas',
          ),
        ],
      ),
      body: cargando
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : productos.isEmpty
              ? const Center(
                  child: Text(
                    'No hay productos disponibles',
                  ),
                )
              : RefreshIndicator(
                  onRefresh: cargarProductos,
                  child: ListView.builder(
                    itemCount: productos.length,
                    itemBuilder: (context, index) {
                      return ProductoCard(
                        producto: productos[index],
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: abrirCarrito,
        child: const Icon(Icons.shopping_cart),
      ),
    );
  }
}