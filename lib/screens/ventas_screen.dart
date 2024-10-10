import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class VentasScreen extends StatefulWidget {
  const VentasScreen({super.key});

  @override
  _VentasScreenState createState() => _VentasScreenState();
}

class _VentasScreenState extends State<VentasScreen> {
  List<dynamic> _ventas = [];
  bool _isLoading = true;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _fetchVentas();
    _startPolling(); // Iniciar el polling
  }

  @override
  void dispose() {
    _pollingTimer?.cancel(); // Cancelar el temporizador al destruir el widget
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchVentas(); // Actualizar las ventas cada 5 segundos
    });
  }

  Future<void> _fetchVentas() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3005/api/ventas'));

      if (response.statusCode == 200) {
        setState(() {
          _ventas = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load ventas');
      }
    } catch (e) {
      print('Error fetching ventas: $e');
    }
  }

  Future<void> _fetchVentaDetalles(int idVenta) async {
    try {
      final responseVenta = await http.get(Uri.parse('http://localhost:3005/api/ventas/$idVenta'));

      if (responseVenta.statusCode == 200) {
        dynamic venta = json.decode(responseVenta.body);

        if (venta['cliente_id'] != null) {
          final responseCliente = await http.get(Uri.parse('http://localhost:3005/api/clientes/${venta['cliente_id']}'));
          if (responseCliente.statusCode == 200) {
            venta['cliente'] = json.decode(responseCliente.body);
          }
        }

        Map<String, dynamic> productos = {};
        if (venta['detalles'] != null) {
          for (var detalle in venta['detalles']) {
            final responseProducto = await http.get(Uri.parse('http://localhost:3005/api/productos/${detalle['id_producto']}'));
            if (responseProducto.statusCode == 200) {
              productos[detalle['id_producto'].toString()] = json.decode(responseProducto.body);
            }
          }
        }

        _showDetails(venta, productos);
      } else {
        throw Exception('Failed to load venta details');
      }
    } catch (e) {
      print('Error fetching venta details: $e');
    }
  }

  void _showDetails(dynamic venta, Map<String, dynamic> productos) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Detalles de la Venta'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                if (venta['cliente'] != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Información del Cliente', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('ID Cliente: ${venta['cliente']['id_cliente']}'),
                      Text('Nombre: ${venta['cliente']['nombre']}'),
                      Text('Contacto: ${venta['cliente']['contacto']}'),
                    ],
                  ),
                const SizedBox(height: 16),
                const Text('Detalles de la Venta', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: (venta['detalles'] ?? []).map<Widget>((detalle) {
                    final producto = productos[detalle['id_producto'].toString()] ?? {};
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Producto: ${producto['nombre'] ?? 'Producto no encontrado'}'),
                          Text('Cantidad: ${detalle['cantidad']?.toString() ?? '0'}'),
                          Text(
                            'Precio Unitario: \$${double.tryParse(detalle['precio_unitario']?.toString() ?? '0')?.toStringAsFixed(2) ?? '0.00'}',
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text('Motivo Anulación: ${venta['anulacion'] ?? 'N/A'}'),
                Text('Total: \$${(venta['total'] ?? 0.0).toString()}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Ventas'),
        backgroundColor: const Color.fromARGB(255, 237, 226, 228),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: _ventas.map((venta) {
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(venta['cliente']['nombre'] ?? 'Desconocido'),
                      subtitle: Text('Fecha de Venta: ${venta['fecha_venta'].split('T')[0]}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.visibility),
                        onPressed: () => _fetchVentaDetalles(venta['id_venta']),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
    );
  }
}
