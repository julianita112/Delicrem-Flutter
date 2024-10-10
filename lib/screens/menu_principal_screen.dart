import 'package:flutter/material.dart';
import 'package:frontend/screens/compras_screen.dart';
import 'package:frontend/screens/loginpage.dart';
import 'package:frontend/screens/ventas_screen.dart';




class MenuPrincipalScreen extends StatelessWidget {
  const MenuPrincipalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Menú Principal',
          style: TextStyle(
            color: Colors.black87, 
            fontStyle: FontStyle.italic, 
            fontSize: 20,
          ),
          textAlign: TextAlign.center, 
        ),
        backgroundColor: const Color.fromARGB(255, 237, 226, 228), 
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            icon: const Icon(Icons.exit_to_app, color: Colors.black87), 
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const VentasScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 138, 43, 92), 
                  minimumSize: const Size(300, 70), 
                  elevation: 5, 
                ),
                icon: const Icon(Icons.shopping_cart, color: Colors.white), 
                label: const Text(
                  'Módulo de Ventas',
                  style: TextStyle(
                    fontSize: 20, 
                    color: Colors.white, 
                    fontStyle: FontStyle.italic
                  ), 
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ComprasScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 0, 0), 
                  minimumSize: const Size(300, 70), 
                  elevation: 5, 
                ),
                icon: const Icon(Icons.shopping_bag, color: Colors.white), 
                label: const Text(
                  'Módulo de Compras',
                  style: TextStyle(
                    fontSize: 20, 
                    color: Colors.white, 
                    fontStyle: FontStyle.italic
                  ), 
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
