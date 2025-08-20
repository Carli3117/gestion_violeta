import 'package:flutter/material.dart';
import '../models/tarea.dart';

class TareaDetalleScreen extends StatelessWidget {
  final Tarea tarea;
  const TareaDetalleScreen({super.key, required this.tarea});

  Color _estadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'hecha': return Colors.green;
      case 'progreso': return Colors.orange;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F0FF),
      appBar: AppBar(
        backgroundColor: Colors.purple[700],
        title: Text(tarea.titulo, style: const TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Chip(
              label: Text(tarea.estado),
              backgroundColor: _estadoColor(tarea.estado).withOpacity(0.12),
              labelStyle: TextStyle(
                color: _estadoColor(tarea.estado),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              tarea.descripcion ?? 'Sin descripción',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Text('Proyecto: ${tarea.proyecto.nombre}'),
            Text('Asignado a: ${tarea.asignado.nombre}'),
            Text('Correo: ${tarea.asignado.correo}'),
            const SizedBox(height: 24),
            Text('Prioridad: ${tarea.prioridad}'),
            Text('Fecha: ${tarea.fechaCreacion.toLocal().toString().split(' ')[0]}'),
          ],
        ),
      ),
    );
  }
}
