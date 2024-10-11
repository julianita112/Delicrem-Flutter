import 'package:flutter/material.dart';
import 'package:frontend/screens/menu_principal_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? errorMessage;

  // Función para manejar el login
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        errorMessage = null;
      });

      final correoElectronico = emailController.text;
      final contrasena = passwordController.text;

      // Validación de campos vacíos
      if (correoElectronico.isEmpty || contrasena.isEmpty) {
        setState(() {
          errorMessage = 'Por favor, completa todos los campos.';
        });
        return;
      }

      print('Correo electrónico ingresado: $correoElectronico');
      print('Contraseña ingresada: $contrasena');

      try {
        final response = await http.post(
          Uri.parse('https://finalbackenddelicremm.onrender.com/api/usuarios/login'), // Cambia por tu IP de backend
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': correoElectronico,
            'password': contrasena,
          }),
        );

        print("Código de estado de la respuesta: ${response.statusCode}");
        print("Cuerpo de la respuesta: ${response.body}");

        if (response.statusCode == 200) {
          // Aquí solo navegamos al menú principal
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MenuPrincipalScreen()),
          );
        } else {
          // Manejo de errores más específico
          if (response.statusCode == 404) {
            setState(() {
              errorMessage = 'Usuario no encontrado. Verifica tu correo.';
            });
          } else if (response.statusCode == 400) {
            setState(() {
              errorMessage = 'Contraseña incorrecta.';
            });
          } else {
            setState(() {
              errorMessage = 'Error de red. Inténtalo de nuevo más tarde.';
            });
          }
        }
      } catch (e) {
        print("Error durante la solicitud: $e");
        setState(() {
          errorMessage = 'Error de red. Inténtalo de nuevo más tarde.';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo blanco
          Container(
            color: const Color.fromARGB(33, 162, 75, 136), // Cambiamos el fondo a blanco
          ),
          // Contenido del formulario
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 255), // Color de fondo gris
                  borderRadius: BorderRadius.circular(12), // Bordes redondeados
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromARGB(63, 0, 0, 0), // Color de la sombra
                      blurRadius: 10.0, // Difuminado de la sombra
                      offset: Offset(0, 4), // Desplazamiento de la sombra
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Contenedor para el logo
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        alignment: Alignment.center,
                        child: Image.asset(
                          'lib/img/delicremlogo.png', // Cambia por tu logo
                          height: 60.0, // Ajusta el tamaño del logo
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Formulario de login
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Campo de email
                            TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(color: Colors.black), // Letra negra en el campo de texto
                              decoration: InputDecoration(
                                labelText: 'Correo electrónico',
                                labelStyle: const TextStyle(color: Colors.black), // Cambiamos la letra de la etiqueta a negro
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.8),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.black), // Cambiamos el borde a negro
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.black), // Cambiamos el borde a negro cuando se enfoca
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa tu correo';
                                }
                                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                  return 'Ingresa un correo válido';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            // Campo de contraseña
                            TextFormField(
                              controller: passwordController,
                              obscureText: true,
                              style: const TextStyle(color: Colors.black), // Letra negra en el campo de texto
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                labelStyle: const TextStyle(color: Colors.black), // Cambiamos la letra de la etiqueta a negro
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.8),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.black), // Cambiamos el borde a negro
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.black), // Cambiamos el borde a negro cuando se enfoca
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa tu contraseña';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            // Botón de login
                            _isLoading
                                ? const CircularProgressIndicator()
                                : ElevatedButton(
                                    onPressed: _login,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 80, vertical: 15),
                                      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                                      textStyle: const TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white, // Letra blanca en el botón
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text(
                                      'Iniciar sesión',
                                      style: TextStyle(
                                        color: Colors.white, // Letra blanca
                                      ),
                                    ),
                                  ),
                            const SizedBox(height: 10),
                            // Mostrar mensajes de error si hay
                            if (errorMessage != null)
                              Text(
                                errorMessage!,
                                style: const TextStyle(color: Colors.black),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
