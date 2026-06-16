import 'package:flutter/material.dart';

class ClienteDashboardPage extends StatelessWidget {
  const ClienteDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
      ),
      body: const Center(
        child: Text('Bienvenido Cliente'),
      ),
    );
  }
}