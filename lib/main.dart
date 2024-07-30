import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import "package:http/http.dart" as http;
import 'dart:convert' show json;

Future<void> main() async => runApp(const CepApp());

class CepApp extends StatelessWidget {
  const CepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Consulta CEP',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CepScreen(),
      debugShowCheckedModeBanner: false, // Remover a etiqueta de debug
    );
  }
}

class CepScreen extends StatefulWidget {
  const CepScreen({super.key});

  @override
  _CepScreenState createState() => _CepScreenState();
}

class _CepScreenState extends State<CepScreen> {
  final TextEditingController _cepController = TextEditingController();
  Map<String, dynamic>? _cepData;
  bool _isLoading = false;

  Future<void> _searchCep() async {
    final cep = _cepController.text;
    if (cep.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response =
          await http.get(Uri.parse('https://viacep.com.br/ws/$cep/json/'));
      if (response.statusCode == 200) {
        setState(() {
          _cepData = json.decode(response.body);
        });
      } else {
        setState(() {
          _cepData = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Erro ao buscar o CEP.'),
        ));
      }
    } catch (e) {
      setState(() {
        _cepData = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Erro ao buscar o CEP.'),
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearData() {
    setState(() {
      _cepController.clear();
      _cepData = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Consulta CEP',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Color.fromARGB(255, 52, 13, 196),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _cepController,
              decoration: const InputDecoration(
                labelText: 'Digite o CEP',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _searchCep,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text(
                      'Consultar',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Color.fromARGB(255, 52, 13, 196), // Cor do botão
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _clearData,
              child: const Text(
                'Limpar Dados',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Color.fromARGB(255, 52, 13, 196), // Cor do botão
              ),
            ),
            const SizedBox(height: 20),
            if (_cepData != null) ...[
              Text('Logradouro: ${_cepData!['logradouro']}'),
              Text('Bairro: ${_cepData!['bairro']}'),
              Text('Cidade: ${_cepData!['localidade']}'),
              Text('Estado: ${_cepData!['uf']}'),
              Text('CEP: ${_cepData!['cep']}'),
            ],
          ],
        ),
      ),
    );
  }
}