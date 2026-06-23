import '../../catalogo/models/producto.dart';

class CarritoItem {
  final Producto producto;

  int cantidad;

  CarritoItem({
    required this.producto,
    this.cantidad = 1,
  });

  double get precioUnitario => producto.precio;

  double get subtotal => precioUnitario * cantidad;

  void aumentarCantidad() {
    cantidad++;
  }

  void disminuirCantidad() {
    if (cantidad > 1) {
      cantidad--;
    }
  }

  void cambiarCantidad(int nuevaCantidad) {
    if (nuevaCantidad > 0) {
      cantidad = nuevaCantidad;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "id_producto": producto.id,
      "nombre": producto.nombre,
      "precio": producto.precio,
      "cantidad": cantidad,
      "subtotal": subtotal,
    };
  }

  factory CarritoItem.fromJson(Map<String, dynamic> json) {
    return CarritoItem(
      producto: Producto(
        id: json["id_producto"],
        nombre: json["nombre"],
        descripcion: json["descripcion"] ?? "",
        precio: double.tryParse(
              json["precio"].toString(),
            ) ??
            0,
      ),
      cantidad: json["cantidad"] ?? 1,
    );
  }
}