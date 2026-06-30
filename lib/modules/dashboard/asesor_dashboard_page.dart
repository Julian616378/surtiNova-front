import 'package:flutter/material.dart';

import 'package:surti_nova/modules/asesor/page/cartera_page.dart';
import 'package:surti_nova/modules/asesor/page/visitas_page.dart';
import 'package:surti_nova/modules/asesor/page/muestras_page.dart';
import 'package:surti_nova/modules/asesor/page/comisiones_page.dart';

class AsesorDashboardPage extends StatefulWidget {
  const AsesorDashboardPage({super.key});

  @override
  State<AsesorDashboardPage> createState() => _AsesorDashboardPageState();
}

class _AsesorDashboardPageState extends State<AsesorDashboardPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    CarteraPage(),
    VisitasPage(),
    MuestrasPage(),
    ComisionesPage(),
  ];

  final List<BottomNavigationBarItem> _navItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.store),       label: 'Cartera'),
    BottomNavigationBarItem(icon: Icon(Icons.directions_walk), label: 'Visitas'),
    BottomNavigationBarItem(icon: Icon(Icons.science),     label: 'Muestras'),
    BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'Comisiones'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: _navItems,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}