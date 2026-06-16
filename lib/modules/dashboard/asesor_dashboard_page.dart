import 'package:flutter/material.dart';
import 'package:surti_nova/shared/widgets/global_app_bar.dart';

class AsesorDashboardPage extends StatelessWidget {
  const AsesorDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GlobalAppBar(
        title: 'Panel Asesor',
      ),
      body: const Center(
        child: Text('Bienvenido Asesor'),
      ),
    );
  }
}