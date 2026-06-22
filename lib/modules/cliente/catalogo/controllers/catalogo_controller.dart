import '../models/producto.dart';
import '../services/producto_service.dart';

class CatalogoController {
  final ProductoService _service = ProductoService();

  Future<List<Producto>> obtenerProductos() async {
    final response =
        await _service.obtenerProductos();

    final List productos =
        response['data'] ?? [];

    return productos
        .map(
          (json) => Producto.fromJson(json),
        )
        .toList();
  }
}