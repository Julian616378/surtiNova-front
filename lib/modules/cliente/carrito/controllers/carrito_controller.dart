import '../models/carrito_item.dart';
import '../../catalogo/models/producto.dart';

class CarritoController {
  static final List<CarritoItem> items = [];

  static void agregarProducto(
    Producto producto,
  ) {
    final index = items.indexWhere(
      (item) => item.producto.id == producto.id,
    );

    if (index != -1) {
      items[index].cantidad++;
    } else {
      items.add(
        CarritoItem(
          producto: producto,
        ),
      );
    }
  }

  static void eliminarProducto(
    int productoId,
  ) {
    items.removeWhere(
      (item) => item.producto.id == productoId,
    );
  }

  static double get total {
    double total = 0;

    for (var item in items) {
      total += item.subtotal;
    }

    return total;
  }
}