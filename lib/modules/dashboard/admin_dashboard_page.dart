import 'package:flutter/material.dart';
import '../../shared/widgets/global_app_bar.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GlobalAppBar(
        title: 'Panel Administrador',
      ),
      body: const Center(
        child: Text(
          'Bienvenido Administrador',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}