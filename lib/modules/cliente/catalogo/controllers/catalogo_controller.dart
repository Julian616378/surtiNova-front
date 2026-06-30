import 'package:flutter/material.dart';
import '../models/categoria_model.dart';
import '../models/producto_model.dart';
import '../services/catalogo_service.dart';

class CatalogoController extends ChangeNotifier {
  final CatalogoService _service = CatalogoService();

  List<CategoriaModel> categorias         = [];
  List<ProductoModel>  productos          = [];
  List<ProductoModel>  productosFiltrados = [];

  int?   categoriaSeleccionada;
  String busqueda = '';
  bool   cargando = false;
  String? error;

  // Carrito: productoId → cantidad
  final Map<int, int> carrito = {};

  int get totalCarrito => carrito.values.fold(0, (a, b) => a + b);

  Future<void> init(String token) async {
    cargando = true;
    error = null;
    notifyListeners();

    try {
      categorias = await _service.getCategorias(token);
      await _cargarProductos(token);
    } catch (e) {
      error = 'Error al cargar: $e';
    }

    cargando = false;
    notifyListeners();
  }

  Future<void> _cargarProductos(String token) async {
    productos = await _service.getProductos(
      token,
      categoriaId: categoriaSeleccionada,
      busqueda: busqueda.isNotEmpty ? busqueda : null,
    );
    productosFiltrados = productos;
    notifyListeners();
  }

  Future<void> seleccionarCategoria(String token, int? id) async {
    categoriaSeleccionada = id;
    cargando = true;
    notifyListeners();
    await _cargarProductos(token);
    cargando = false;
    notifyListeners();
  }

  Future<void> buscar(String token, String query) async {
    busqueda = query;
    await _cargarProductos(token);
  }

  void agregarAlCarrito(int productoId, {int cantidad = 1}) {
    carrito[productoId] = (carrito[productoId] ?? 0) + cantidad;
    notifyListeners();
  }

  void quitarDelCarrito(int productoId) {
    if (carrito.containsKey(productoId)) {
      if (carrito[productoId]! > 1) {
        carrito[productoId] = carrito[productoId]! - 1;
      } else {
        carrito.remove(productoId);
      }
      notifyListeners();
    }
  }

  int cantidadEnCarrito(int productoId) => carrito[productoId] ?? 0;
}