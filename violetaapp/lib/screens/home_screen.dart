import 'package:flutter/material.dart';
import '../models/usuario.dart';

class HomeScreen extends StatelessWidget {
  final Usuario usuario;
  const HomeScreen({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Panel Principal"),
        backgroundColor: Colors.purple[800],
      ),
      body: Center(
        child: Card(
          elevation: 10,
          margin: const EdgeInsets.all(32),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_user, color: Colors.purple, size: 64),
                const SizedBox(height: 20),
                Text(
                  "¡Bienvenido, ${usuario.nombre}!",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  "Correo: ${usuario.correo}",
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    // Aquí puedes navegar al Dashboard o cerrar sesión
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[700],
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  icon: const Icon(Icons.dashboard),
                  label: const Text("Ir al Dashboard"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
