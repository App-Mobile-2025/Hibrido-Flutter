import 'package:flutter/material.dart';
import 'package:reciclapp/ui/canje/canjeScrean.dart';
import 'package:reciclapp/ui/configuracion/config_screen.dart';
import 'package:reciclapp/ui/munditoIA/mundito_bottom_sheet.dart';
import '../perfil/perfil_screen.dart';
import 'package:reciclapp/ui/gestion/gestion_screen.dart';
import '../register/registrar_reciclaje_screen.dart';

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

  final List<Widget> _pages = [
    const SizedBox.shrink(),
    const RegistrarReciclajeScreen(),
    const GestionScreen(),
    const CanjeScreen(),
    const PerfilScreen(),
    const ConfigScreen(),
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

      body: _currentIndex == 0 ? _buildHomeDashboard() : _pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
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

  // -------------------------------------
  // DASHBOARD CON ANIMACIÓN + PNG
  // -------------------------------------
  Widget _buildHomeDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Bienvenido a ReciclApp',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 24),

          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _HomeOptionCard(
                iconPath: 'assets/icons/reciclaje.png',
                label: 'Registrar\nresiduos',
                onTap: () => setState(() => _currentIndex = 1),
              ),
              _HomeOptionCard(
                iconPath: 'assets/icons/gestion.png',
                label: 'Gestión de\nreciclaje',
                onTap: () => setState(() => _currentIndex = 2),
              ),
              _HomeOptionCard(
                iconPath: 'assets/icons/canje.png',
                label: 'Canje',
                onTap: () => setState(() => _currentIndex = 3),
              ),
              _HomeOptionCard(
                iconPath: 'assets/icons/perfil.png',
                label: 'Perfil',
                onTap: () => setState(() => _currentIndex = 4),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------
// CARD ANIMADA CON PNG
// -------------------------------------------------
class _HomeOptionCard extends StatefulWidget {
  final String iconPath;
  final String label;
  final VoidCallback onTap;

  const _HomeOptionCard({
    super.key,
    required this.iconPath,
    required this.label,
    required this.onTap,
  });

  @override
  State<_HomeOptionCard> createState() => _HomeOptionCardState();
}

class _HomeOptionCardState extends State<_HomeOptionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: widget.onTap,
        onHighlightChanged: (value) {
          setState(() {
            _isPressed = value;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.green.shade100,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 6,
                offset: const Offset(0, 3),
                color: Colors.black.withOpacity(0.05),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.shade50,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    widget.iconPath,
                    width: 52,
                    height: 52,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                widget.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
