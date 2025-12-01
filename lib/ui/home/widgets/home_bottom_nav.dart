import 'package:flutter/material.dart';

class HomeBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const HomeBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: onTap,
      items: [
        BottomNavigationBarItem(
          icon: Image.asset('assets/icons/home.png', height: 26),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/icons/reciclaje.png', height: 26),
          label: 'Registrar',
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/icons/gestion.png', height: 26),
          label: 'Gestión',
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/icons/canje.png', height: 26),
          label: 'Canje',
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/icons/perfil.png', height: 26),
          label: 'Perfil',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.tune),
          label: 'Config',
        ),
      ],
    );
  }
}
