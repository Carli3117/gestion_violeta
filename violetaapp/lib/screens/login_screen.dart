import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/usuario.dart';
import 'menu_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

void _login() async {
  setState(() { _isLoading = true; _error = null; });

  final correo = _correoController.text.trim();
  final password = _passwordController.text.trim();
  if (correo.isEmpty || password.isEmpty) {
    setState(() { _isLoading = false; _error = 'Ingresa correo y contraseña'; });
    return;
  }

  final response = await ApiService.login(correo, password);
  setState(() => _isLoading = false);

  if (response['success'] == true) {
    final usuario = Usuario.fromJson(response);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MenuScreen(usuario: usuario)),
    );
  } else {
    setState(() => _error = response['message'] ?? 'Error al iniciar sesión');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F0FF),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Card(
            elevation: 10,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.account_circle, color: Colors.purple, size: 70),
                  const SizedBox(height: 16),
                  Text("VIOLETA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: Colors.purple[800], letterSpacing: 2)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _correoController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: "Correo", prefixIcon: Icon(Icons.email)),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Contraseña", prefixIcon: Icon(Icons.lock)),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[600],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Iniciar Sesión", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(_error!, style: const TextStyle(color: Colors.red)),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
