class TiendaModel {
  final int? id;
  final String nombre;
  final String? direccion;
  final String? telefono;
  final String? contacto;
  final String? estado;
  final Map<String, dynamic>? extra;

  TiendaModel({
    this.id,
    required this.nombre,
    this.direccion,
    this.telefono,
    this.contacto,
    this.estado,
    this.extra,
  });

  factory TiendaModel.fromJson(Map<String, dynamic> json) => TiendaModel(
        id:        json['id'],
        nombre:    json['nombre']   ?? '',
        direccion: json['direccion'],
        telefono:  json['telefono'],
        contacto:  json['contacto'],
        estado:    json['estado'],
        extra:     json,
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'nombre':    nombre,
        if (direccion != null) 'direccion': direccion,
        if (telefono  != null) 'telefono':  telefono,
        if (contacto  != null) 'contacto':  contacto,
        if (estado    != null) 'estado':    estado,
      };
}