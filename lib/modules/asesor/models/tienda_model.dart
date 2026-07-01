class TiendaModel {
  final int id;
  final String? nombre;
  final String? nit;
  final String? propietario;
  final String? telefono;
  final String? correo;
  final String? direccion;
  final double? latitud;
  final double? longitud;
  final String estado;
  final int idAsesor;

  String get displayName => (nombre?.isNotEmpty == true) ? nombre! : 'Sin nombre';
  String get displayPropietario => propietario ?? '—';
  String get email => correo ?? '';

  TiendaModel({
    required this.id,
    this.nombre,
    this.nit,
    this.propietario,
    this.telefono,
    this.correo,
    this.direccion,
    this.latitud,
    this.longitud,
    this.estado = 'prospecto',
    required this.idAsesor,
  });

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    return double.tryParse(value.toString());
  }

  factory TiendaModel.fromJson(Map<String, dynamic> json) {
    return TiendaModel(
      id:          json['id'] ?? 0,
      nombre:      json['nombre'] as String?,
      nit:         json['nit'] as String?,
      propietario: json['propietario'] as String?,
      telefono:    json['telefono'] as String?,
      correo:      json['correo'] as String?,
      direccion:   json['direccion'] as String?,
      latitud:     _parseDouble(json['latitud']),
      longitud:    _parseDouble(json['longitud']),
      estado:      json['estado'] as String? ?? 'prospecto',
      idAsesor:    json['id_asesor'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'nombre': nombre, 'nit': nit,
    'propietario': propietario, 'telefono': telefono,
    'correo': correo, 'direccion': direccion,
    'latitud': latitud, 'longitud': longitud,
    'estado': estado, 'id_asesor': idAsesor,
  };
}