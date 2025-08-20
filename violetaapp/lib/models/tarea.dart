class ProyectoRef {
  final int idproyecto;
  final String nombre;
  ProyectoRef({required this.idproyecto, required this.nombre});
  factory ProyectoRef.fromJson(Map<String, dynamic> j) =>
      ProyectoRef(idproyecto: j['idproyecto'], nombre: j['nombre'] ?? '');
}

class AsignadoRef {
  final int idusuario;
  final String nombre;
  final String correo;
  AsignadoRef({required this.idusuario, required this.nombre, required this.correo});
  factory AsignadoRef.fromJson(Map<String, dynamic> j) => AsignadoRef(
    idusuario: j['idusuario'],
    nombre: j['nombre'] ?? '',
    correo: j['correo'] ?? '',
  );
}

class Tarea {
  final int idtarea;
  final String titulo;
  final String? descripcion;
  final String estado;
  final String prioridad;
  final DateTime fechaCreacion;
  final ProyectoRef proyecto;
  final AsignadoRef asignado;

  Tarea({
    required this.idtarea,
    required this.titulo,
    this.descripcion,
    required this.estado,
    required this.prioridad,
    required this.fechaCreacion,
    required this.proyecto,
    required this.asignado,
  });

  factory Tarea.fromJson(Map<String, dynamic> j) => Tarea(
    idtarea: j['idtarea'],
    titulo: j['titulo'] ?? '',
    descripcion: j['descripcion'],
    estado: j['estado'] ?? 'pendiente',
    prioridad: j['prioridad'] ?? 'media',
    fechaCreacion: DateTime.tryParse(j['fecha_creacion'] ?? '') ?? DateTime.now(),
    proyecto: ProyectoRef.fromJson(j['proyecto']),
    asignado: AsignadoRef.fromJson(j['asignado']),
  );
}
