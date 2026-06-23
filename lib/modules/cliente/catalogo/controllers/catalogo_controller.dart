import '../models/producto.dart';
import '../services/producto_service.dart';

class CatalogoController {
  final ProductoService _service = ProductoService();

  Future<List<Producto>> obtenerProductos({
    String buscar = '',
  }) async {
    final response = await _service.obtenerProductos(
      buscar: buscar,
    );

    final List productos = response['data'] ?? [];

    return productos
        .map(
          (json) => Producto.fromJson(json),
        )
        .toList();
  }
}