import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tarea.dart';

class ApiService {
  // Cambia esto según tu entorno:
  // Emulador Android: http://10.0.2.2:5000
  // Flutter Desktop: http://localhost:5000
  // Dispositivo físico: http://TU_IP_LOCAL:5000
static const String baseUrl = 'http://192.168.1.14:5000';



  /// Login de usuario
  static Future<Map<String, dynamic>> login(String correo, String password) async {
    final url = Uri.parse('$baseUrl/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'correo': correo, 'password': password}),
      ).timeout(const Duration(seconds: 10));

      Map<String, dynamic> body;
      try {
        body = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      } catch (_) {
        return {'success': false, 'message': 'Respuesta no válida del servidor'};
      }

      if (response.statusCode == 200) return body;
      return {'success': false, 'message': body['message'] ?? 'Error ${response.statusCode}'};
    } catch (_) {
      return {'success': false, 'message': 'No se pudo conectar al servidor'};
    }
  }

  /// Clase auxiliar para respuesta de tareas
  static Future<TareaResponse> getTareas({
    String q = '',
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = {
      'page': '$page',
      'page_size': '$pageSize',
      if (q.trim().isNotEmpty) 'q': q.trim(),
    };

    final url = Uri.parse('$baseUrl/tareas').replace(queryParameters: queryParams);
    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Error al obtener tareas: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body);
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Respuesta inválida');
    }

    final list = (data['items'] as List).map((e) => Tarea.fromJson(e)).toList();
    return TareaResponse(items: list, total: data['total'] ?? list.length);
  }
}

/// Clase para encapsular la respuesta de tareas
class TareaResponse {
  final List<Tarea> items;
  final int total;

  TareaResponse({required this.items, required this.total});
}
