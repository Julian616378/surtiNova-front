import '../models/carrito_item.dart';
import '../../catalogo/models/producto.dart';

class CarritoController {
  static final List<CarritoItem> items = [];

  /// Agregar producto al carrito
  static void agregarProducto(Producto producto) {
    final index = items.indexWhere(
      (item) => item.producto.id == producto.id,
    );

    if (index != -1) {
      items[index].aumentarCantidad();
    } else {
      items.add(
        CarritoItem(
          producto: producto,
          cantidad: 1,
        ),
      );
    }
  }

  /// Aumentar cantidad
  static void aumentarCantidad(int productoId) {
    final index = items.indexWhere(
      (item) => item.producto.id == productoId,
    );

    if (index != -1) {
      items[index].aumentarCantidad();
    }
  }

  /// Disminuir cantidad
  static void disminuirCantidad(int productoId) {
    final index = items.indexWhere(
      (item) => item.producto.id == productoId,
    );

    if (index != -1) {
      if (items[index].cantidad > 1) {
        items[index].disminuirCantidad();
      } else {
        items.removeAt(index);
      }
    }
  }

  /// Cambiar cantidad manualmente
  static void cambiarCantidad(
    int productoId,
    int cantidad,
  ) {
    final index = items.indexWhere(
      (item) => item.producto.id == productoId,
    );

    if (index != -1 && cantidad > 0) {
      items[index].cantidad = cantidad;
    }
  }

  /// Eliminar un producto
  static void eliminarProducto(int productoId) {
    items.removeWhere(
      (item) => item.producto.id == productoId,
    );
  }

  /// Vaciar carrito
  static void vaciarCarrito() {
    items.clear();
  }

  /// Total del carrito
  static double get total {
    return items.fold(
      0,
      (total, item) => total + item.subtotal,
    );
  }

  /// Cantidad total de unidades
  static int get totalUnidades {
    return items.fold(
      0,
      (total, item) => total + item.cantidad,
    );
  }

  /// Cantidad de productos diferentes
  static int get totalProductos {
    return items.length;
  }

  /// Saber si está vacío
  static bool get estaVacio {
    return items.isEmpty;
  }

  /// Convierte el carrito al formato del API Laravel
  static List<Map<String, dynamic>> get itemsPedido {
    return items.map((item) {
      return {
        "id_producto": item.producto.id,
        "cantidad": item.cantidad,
      };
    }).toList();
  }

  /// Resumen del pedido
  static Map<String, dynamic> get resumen {
    return {
      "productos": totalProductos,
      "unidades": totalUnidades,
      "total": total,
    };
  }
}