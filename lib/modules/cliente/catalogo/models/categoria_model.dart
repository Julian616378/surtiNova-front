class CategoriaModel {
  final int    id;
  final String nombre;
  final String? icono;

  CategoriaModel({required this.id, required this.nombre, this.icono});

  factory CategoriaModel.fromJson(Map<String, dynamic> j) => CategoriaModel(
    id:     j['id'],
    nombre: j['nombre'] ?? '',
    icono:  j['icono'],
  );
}