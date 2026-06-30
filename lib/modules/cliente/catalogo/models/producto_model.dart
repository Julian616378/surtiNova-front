class ProductoModel {
  final int     id;
  final String  nombre;
  final String? descripcion;
  final double  precio;
  final int     stock;
  final String? imagen;
  final String? presentacion;
  final int     contenido;
  final String? unidadMedida;
  final int     piezasPorCaja;
  final bool    tieneAzucar;
  final int     categoriaId;

  ProductoModel({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.precio,
    required this.stock,
    this.imagen,
    this.presentacion,
    required this.contenido,
    this.unidadMedida,
    required this.piezasPorCaja,
    required this.tieneAzucar,
    required this.categoriaId,
  });

  bool get enStock => stock > 0;

  factory ProductoModel.fromJson(Map<String, dynamic> j) => ProductoModel(
    id:            j['id'],
    nombre:        j['nombre'] ?? '',
    descripcion:   j['descripcion'],
    precio:        double.tryParse(j['precio'].toString()) ?? 0.0,
    stock:         j['stock'] ?? 0,
    imagen:        j['imagen'],
    presentacion:  j['presentacion'],
    contenido:     j['contenido'] ?? 1,
    unidadMedida:  j['unidad_medida'],
    piezasPorCaja: j['piezas_por_caja'] ?? 1,
    tieneAzucar:   j['tiene_azucar'] == true || j['tiene_azucar'] == 1,
    categoriaId:   j['id_categoria'] ?? 0,
  );
}