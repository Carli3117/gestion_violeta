import 'package:flutter/material.dart';
import '../models/usuario.dart';
import 'tareas_screen.dart';

class MenuScreen extends StatelessWidget {
  final Usuario usuario;
  const MenuScreen({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      {
        "title": "Tareas",
        "icon": Icons.check_circle_outline,
        "color": Colors.purple
      },
      {
        "title": "Proyectos",
        "icon": Icons.folder_open,
        "color": Colors.blue
      },
      {
        "title": "Comentarios",
        "icon": Icons.chat_bubble_outline,
        "color": Colors.teal
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple[700],
        elevation: 0,
        title: const Text("Menú Principal", style: TextStyle(color: Colors.white)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                usuario.nombre.isNotEmpty ? usuario.nombre[0].toUpperCase() : "?",
                style: TextStyle(color: Colors.purple[700], fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
      backgroundColor: const Color(0xFFF3F0FF),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.builder(
          itemCount: menuItems.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
          ),
          itemBuilder: (context, index) {
            final item = menuItems[index];
            return GestureDetector(
              onTap: () {
                if (item['title'] == "Tareas") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TareasScreen(usuario: usuario),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${item['title']} no implementado aún")),
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(2, 4)),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item["icon"] as IconData, size: 48, color: item["color"] as Color),
                    const SizedBox(height: 12),
                    Text(
                      item["title"] as String,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: item["color"] as Color,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
