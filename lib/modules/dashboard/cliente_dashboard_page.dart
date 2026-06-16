import 'package:flutter/material.dart';
import 'package:surti_nova/shared/widgets/global_app_bar.dart';

class ClienteDashboardPage extends StatelessWidget {
  const ClienteDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GlobalAppBar(
        title: 'Inicio',
      ),
      body: const Center(
        child: Text('Bienvenido Cliente'),
      ),
    );
  }
}