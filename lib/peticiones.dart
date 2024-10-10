import 'package:flutter/material.dart';
import 'package:frontend/screens/menu_principal_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _usernameError = '';
  String _passwordError = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE5E5E5),
              Color(0xFFF5F5F5),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.person_outline_rounded,
                  size: 120,
                  color: Color(0xFFBF616A),
                ),
                const SizedBox(height: 16),
                const Text(
                  'DelicRem+',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 40),
                _buildLoginForm(),
                const SizedBox(height: 20),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField(
            controller: _usernameController,
            labelText: 'Nombre de Usuario',
            errorText: _usernameError,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _passwordController,
            labelText: 'Contraseña',
            obscureText: true,
            errorText: _passwordError,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBF616A),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Iniciar Sesión',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    bool obscureText = false,
    required String errorText,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        errorText: errorText.isNotEmpty ? errorText : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      style: const TextStyle(color: Colors.black),
      cursorColor: Colors.black,
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Text(
          'Por Juliana Nuñez',
          style: TextStyle(
            color: Color(0xFF7D7D7D),
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () {
            // Implementar la navegación a la pantalla de recuperación de contraseña
          },
          child: const Text(
            '¿Olvidaste tu contraseña?',
            style: TextStyle(
              color: Color(0xFFBF616A),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  void _login() async {
    setState(() {
      _isLoading = true;
      _usernameError = '';
      _passwordError = '';
    });

    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username.isEmpty) {
      setState(() {
        _usernameError = 'El campo de nombre de usuario es obligatorio.';
      });
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _passwordError = 'El campo de contraseña es obligatorio.';
      });
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Simular proceso de login
    await Future.delayed(const Duration(seconds: 2));

    if (username == 'admin' && password == '1234') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MenuPrincipalScreen()),
      );
    } else {
      setState(() {
        _usernameError = 'Nombre de usuario o contraseña incorrectos';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }
}
