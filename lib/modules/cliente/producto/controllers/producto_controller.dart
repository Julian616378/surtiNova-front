import 'package:flutter/material.dart';
import '../../catalogo/models/producto_model.dart';
import '../../catalogo/services/catalogo_service.dart';

class ProductoController extends ChangeNotifier {
  final CatalogoService _service = CatalogoService();

  ProductoModel? producto;
  List<ProductoModel> relacionados = [];
  bool   cargando = false;
  String? error;
  int    cantidad  = 1;
  bool   favorito  = false;

  Future<void> init(String token, int id, List<ProductoModel> todos) async {
    cargando = true; notifyListeners();
    try {
      producto    = await _service.getProductoDetalle(token, id);
      relacionados = todos.where((p) => p.id != id && p.categoriaId == producto!.categoriaId).take(3).toList();
      error = null;
    } catch (e) {
      error = e.toString();
    }
    cargando = false; notifyListeners();
  }

  void incrementar() { if (cantidad < 20) { cantidad++; notifyListeners(); } }
  void decrementar() { if (cantidad > 1)  { cantidad--; notifyListeners(); } }
  void toggleFavorito() { favorito = !favorito; notifyListeners(); }
}