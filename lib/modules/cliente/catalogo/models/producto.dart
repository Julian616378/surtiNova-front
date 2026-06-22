class Producto {
  final int id;
  final String nombre;
  final String descripcion;
  final double precio;

  Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      precio:
          double.tryParse(json['precio'].toString()) ?? 0,
    );
  }
}