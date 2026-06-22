import '../../catalogo/models/producto.dart';

class CarritoItem {
  final Producto producto;
  int cantidad;

  CarritoItem({
    required this.producto,
    this.cantidad = 1,
  });

  double get subtotal => producto.precio * cantidad;

  void aumentarCantidad() {
    cantidad++;
  }

  void disminuirCantidad() {
    if (cantidad > 1) {
      cantidad--;
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
        descripcion: "",
        precio: double.parse(json["precio"].toString()),
      ),
      cantidad: json["cantidad"] ?? 1,
    );
  }
}