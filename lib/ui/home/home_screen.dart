import 'package:flutter/material.dart';
import 'package:reciclapp/ui/canje/canjeScrean.dart';
import 'package:reciclapp/ui/configuracion/config_screen.dart';
import 'package:reciclapp/ui/munditoIA/mundito_bottom_sheet.dart';
import 'package:reciclapp/ui/perfil/perfil_screen.dart';
import 'package:reciclapp/ui/gestion/gestion_screen.dart';
import 'package:reciclapp/ui/register/registrar_reciclaje_screen.dart';

// NUEVOS IMPORTS
import 'widgets/home_dashboard.dart';
import 'widgets/home_bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  // Para acceder al state desde otros widgets
  static _HomeScreenState? of(BuildContext context) =>
      context.findAncestorStateOfType<_HomeScreenState>();

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    SizedBox.shrink(),              // índice 0 = dashboard
    RegistrarReciclajeScreen(),
    GestionScreen(),
    CanjeScreen(),
    PerfilScreen(),
    ConfigScreen(),
  ];

  void goToPage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),

      appBar: AppBar(
        title: const Text('ReciclApp'),
        automaticallyImplyLeading: false,
      ),

      body: _currentIndex == 0
          ? HomeDashboard(onNavigateToTab: goToPage)
          : _pages[_currentIndex],

      bottomNavigationBar: HomeBottomNavBar(
        currentIndex: _currentIndex,
        onTap: goToPage,
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (ctx) => const MunditoBottomSheet(),
          );
        },
        backgroundColor: Colors.green.shade600,
        icon: ClipOval(
          child: Image.asset(
            'assets/mundito_icon_v2.png',
            width: 48,
            height: 48,
            fit: BoxFit.cover,
          ),
        ),
        label: const Text('Mundito IA'),
      ),
    );
  }
}
