import 'package:flutter/material.dart';

class AsesorDashboardPage extends StatelessWidget {
  const AsesorDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Asesor'),
      ),
      body: const Center(
        child: Text('Bienvenido Asesor'),
      ),
    );
  }
}
