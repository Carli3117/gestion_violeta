// lib/models/usuario.dart
class Usuario {
  final int idusuario;
  final String nombre;
  final String correo;
  final int? idroll;

  Usuario({
    required this.idusuario,
    required this.nombre,
    required this.correo,
    this.idroll,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
        idusuario: json['idusuario'],
        nombre: json['nombre'],
        correo: json['correo'],
        idroll: json['idroll'],
      );
}
