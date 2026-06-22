import 'package:flutter/material.dart';
import 'package:surti_nova/shared/widgets/global_app_bar.dart';
import '../../catalogo/views/catalogo_page.dart';

class ClienteDashboardPage extends StatelessWidget {
  const ClienteDashboardPage({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GlobalAppBar(
        title: 'Panel cliente',
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CatalogoPage(),
              ),
            );
          },
          child: const Text('catalogo'),
        ),
      ),
    );
  }
}