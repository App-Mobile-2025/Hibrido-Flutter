import 'package:flutter/material.dart';

class HomeDashboard extends StatelessWidget {
  final ValueChanged<int> onNavigateToTab;

  const HomeDashboard({
    super.key,
    required this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
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
              HomeOptionCard(
                iconPath: 'assets/icons/reciclaje.png',
                label: 'Registrar\nresiduos',
                onTap: () => onNavigateToTab(1),
              ),
              HomeOptionCard(
                iconPath: 'assets/icons/gestion.png',
                label: 'Gestión de\nreciclaje',
                onTap: () => onNavigateToTab(2),
              ),
              HomeOptionCard(
                iconPath: 'assets/icons/canje.png',
                label: 'Canje',
                onTap: () => onNavigateToTab(3),
              ),
              HomeOptionCard(
                iconPath: 'assets/icons/perfil.png',
                label: 'Perfil',
                onTap: () => onNavigateToTab(4),
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
class HomeOptionCard extends StatefulWidget {
  final String iconPath;
  final String label;
  final VoidCallback onTap;

  const HomeOptionCard({
    super.key,
    required this.iconPath,
    required this.label,
    required this.onTap,
  });

  @override
  State<HomeOptionCard> createState() => _HomeOptionCardState();
}

class _HomeOptionCardState extends State<HomeOptionCard> {
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
