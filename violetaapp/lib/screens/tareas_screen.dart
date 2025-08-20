import 'dart:async';
import 'package:flutter/material.dart';
import '../models/tarea.dart';
import '../models/usuario.dart';
import '../services/api_service.dart';
import 'tarea_detalle_screen.dart';

class TareasScreen extends StatefulWidget {
  final Usuario usuario;
  const TareasScreen({super.key, required this.usuario});

  @override
  State<TareasScreen> createState() => _TareasScreenState();
}

class _TareasScreenState extends State<TareasScreen> {
  final TextEditingController _search = TextEditingController();
  Timer? _debounce;
  bool _loading = false;
  List<Tarea> _items = [];
  int _total = 0;
  int _page = 1;
  final int _pageSize = 20;
  String _q = '';

  @override
  void initState() {
    super.initState();
    _load();
    _search.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _search.removeListener(_onSearchChanged);
    _search.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      setState(() {
        _q = _search.text;
        _page = 1;
      });
      _load();
    });
  }

  Future<void> _load({bool append = false}) async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.getTareas(q: _q, page: _page, pageSize: _pageSize);
      setState(() {
        _total = res.total;
        _items = append ? [..._items, ...res.items] : res.items;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar tareas: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _loadMore() {
    if (_items.length >= _total || _loading) return;
    setState(() => _page += 1);
    _load(append: true);
  }

  Color _estadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'hecha': return Colors.green;
      case 'progreso': return Colors.orange;
      default: return Colors.grey;
    }
  }

  int _crossAxisForWidth(double w) {
    if (w >= 1200) return 4;
    if (w >= 900) return 3;
    if (w >= 600) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F0FF),
      appBar: AppBar(
        backgroundColor: Colors.purple[700],
        title: const Text('Tareas', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: 'Filtrar por tarea (título)...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _q.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _search.clear();
                          FocusScope.of(context).unfocus();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, cons) {
                final cols = _crossAxisForWidth(cons.maxWidth);
                if (_loading && _items.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (_items.isEmpty) {
                  return const Center(child: Text('Sin tareas'));
                }
                return NotificationListener<ScrollNotification>(
                  onNotification: (sn) {
                    if (sn.metrics.pixels >= sn.metrics.maxScrollExtent - 100) {
                      _loadMore();
                    }
                    return false;
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.5,
                    ),
                    itemCount: _items.length + (_loading && _items.isNotEmpty ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i >= _items.length) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final t = _items[i];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TareaDetalleScreen(tarea: t),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(2,4))],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.task_alt, color: Colors.purple[600]),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      t.titulo,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      maxLines: 1, overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Chip(
                                    label: Text(t.estado),
                                    backgroundColor: _estadoColor(t.estado).withOpacity(0.12),
                                    labelStyle: TextStyle(color: _estadoColor(t.estado), fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                t.descripcion ?? 'Sin descripción',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.black87),
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  const Icon(Icons.folder_open, size: 18, color : Colors.blue),
                                  const Icon(Icons.folder_open, size: 18, color: Colors.blue),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      t.proyecto.nombre,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.person_outline, size: 18, color: Colors.teal),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      t.asignado.nombre,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
