import 'package:flutter/material.dart';
import '../perfil/perfil_screen.dart';
import 'package:reciclapp/ui/gestion/gestion_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // LISTA DE PÁGINAS
  final List<Widget> _pages = [
    const SizedBox.shrink(),      
    const Center(child: Text('Registrar Reciclaje')),
    GestionScreen(),                
    const Center(child: Text('Canje')),
    const PerfilScreen(),
    const Center(child: Text('Configuración')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        title: const Text('ReciclApp'),
        automaticallyImplyLeading: false,
      ),

      body: _currentIndex == 0
          ? _buildHomeDashboard()
          : _pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.recycling), label: 'Registrar'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Gestión'),
          BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: 'Canje'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Config'),
        ],
      ),
    );
  }

  // --------------------------
  // HOME DASHBOARD
  // --------------------------
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
                icon: Icons.delete_outline,
                label: 'Registrar\nresiduos',
                onTap: () => setState(() => _currentIndex = 1),
              ),
              _HomeOptionCard(
                icon: Icons.list_alt,
                label: 'Gestión de\nreciclaje',
                onTap: () => setState(() => _currentIndex = 2),
              ),
              _HomeOptionCard(
                icon: Icons.card_giftcard,
                label: 'Canje',
                onTap: () => setState(() => _currentIndex = 3),
              ),
              _HomeOptionCard(
                icon: Icons.person_outline,
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

// ---------------------------------------------
// CARD CON SOMBRA + ICONO SOMBREADO
// ---------------------------------------------
class _HomeOptionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HomeOptionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
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
              width: 56,
              height: 56,
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
              child: Icon(
                icon,
                size: 32,
                color: Colors.green.shade700,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              label,
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
    );
  }
}
