class TiendaModel {
  final int id;
  final String? razonSocial;
  final String? nit;
  final String? propietario;
  final String? nombreEstablecimiento;
  final String? nombrePropietario;
  final String? telefono;
  final String? email;
  final String? direccion;
  final String? barrio;
  final String? ciudad;
  final String? estado;
  final double? latitud;
  final double? longitud;
  final String? observaciones;

  TiendaModel({
    required this.id,
    this.razonSocial,
    this.nit,
    this.propietario,
    this.nombreEstablecimiento,
    this.nombrePropietario,
    this.telefono,
    this.email,
    this.direccion,
    this.barrio,
    this.ciudad,
    this.estado,
    this.latitud,
    this.longitud,
    this.observaciones,
  });

  // Nombre para mostrar — soporta tanto tienda formal como prospecto
  String get displayName =>
      razonSocial ?? nombreEstablecimiento ?? 'Tienda #$id';

  String get displayPropietario =>
      propietario ?? nombrePropietario ?? '—';

  factory TiendaModel.fromJson(Map<String, dynamic> j) => TiendaModel(
        id:                   j['id'],
        razonSocial:          j['razon_social'],
        nit:                  j['nit'],
        propietario:          j['propietario'],
        nombreEstablecimiento: j['nombre_establecimiento'],
        nombrePropietario:    j['nombre_propietario'],
        telefono:             j['telefono'],
        email:                j['email'],
        direccion:            j['direccion'],
        barrio:               j['barrio'],
        ciudad:               j['ciudad'],
        estado:               j['estado'],
        latitud:              (j['latitud'] as num?)?.toDouble(),
        longitud:             (j['longitud'] as num?)?.toDouble(),
        observaciones:        j['observaciones'],
      );
}