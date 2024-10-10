import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // Importar para usar Timer

class ComprasScreen extends StatefulWidget {
  const ComprasScreen({super.key});

  @override
  _ComprasScreenState createState() => _ComprasScreenState();
}

class _ComprasScreenState extends State<ComprasScreen> {
  List<dynamic> _compras = [];
  bool _isLoading = true;
  Timer? _timer; // Variable para el Timer

  @override
  void initState() {
    super.initState();
    _fetchCompras();
    _startPolling(); // Iniciar el polling
  }

  void _startPolling() {
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      _fetchCompras(); // Llama a _fetchCompras cada 10 segundos
    });
  }

  Future<void> _fetchCompras() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3005/api/compras'));

      if (response.statusCode == 200) {
        setState(() {
          _compras = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load compras');
      }
    } catch (e) {
      print('Error fetching compras: $e');
    }
  }

  Future<void> _fetchCompraDetalles(int idCompra) async {
    try {
      final responseCompra = await http.get(Uri.parse('http://localhost:3005/api/compras/$idCompra'));

      if (responseCompra.statusCode == 200) {
        final compra = json.decode(responseCompra.body);

        // Obtener detalles del proveedor
        final responseProveedor = await http.get(Uri.parse('http://localhost:3005/api/proveedores/${compra['id_proveedor']}'));
        final proveedor = responseProveedor.statusCode == 200 ? json.decode(responseProveedor.body) : {};

        // Obtener detalles de los insumos
        final responseInsumos = await http.get(Uri.parse('http://localhost:3005/api/insumos'));
        final insumos = responseInsumos.statusCode == 200 ? json.decode(responseInsumos.body) : [];

        // Mostrar detalles en un diálogo
        _showDetails(compra, proveedor, insumos);
      } else {
        throw Exception('Failed to load compra details');
      }
    } catch (e) {
      print('Error fetching compra details: $e');
    }
  }

  void _showDetails(dynamic compra, dynamic proveedor, List<dynamic> insumos) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Detalles de la Compra'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Número de Recibo: ${compra['numero_recibo'] ?? 'N/A'}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (proveedor.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Información del Proveedor',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('ID Proveedor: ${proveedor['id_proveedor'] ?? 'N/A'}'),
                      Text('Nombre: ${proveedor['nombre'] ?? 'N/A'}'),
                      Text('Contacto: ${proveedor['contacto'] ?? 'N/A'}'),
                    ],
                  ),
                const SizedBox(height: 16),
                const Text('Detalles de la Compra', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: (compra['detalleComprasCompra'] ?? []).map<Widget>((detalle) {
                    final insumo = insumos.firstWhere(
                      (insumo) => insumo['id_insumo'] == detalle['id_insumo'],
                      orElse: () => {},
                    );
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Insumo: ${insumo['nombre'] ?? 'Desconocido'}'),
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
                Text('Motivo Anulación: ${compra['anulacion'] ?? 'N/A'}'),
                Text('Total: \$${(compra['total'] ?? 0.0).toString()}'),
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
  void dispose() {
    _timer?.cancel(); // Cancelar el Timer al salir de la pantalla
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Compras'),
        backgroundColor: const Color.fromARGB(255, 237, 226, 228),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: _compras.map((compra) {
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(compra['proveedorCompra']?['nombre'] ?? 'Desconocido'),
                      subtitle: Text('Fecha de Compra: ${compra['fecha_compra'].split('T')[0]}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.visibility),
                        onPressed: () => _fetchCompraDetalles(compra['id_compra']),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
    );
  }
}
