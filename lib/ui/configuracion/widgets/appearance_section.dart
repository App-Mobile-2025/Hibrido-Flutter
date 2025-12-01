import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:reciclapp/ui/configuracion/provider/appearance_provider.dart';

class AppearanceConfigSection extends StatelessWidget {
  const AppearanceConfigSection({super.key});

  @override
  Widget build(BuildContext context) {
    final appearance = context.watch<AppearanceProvider>();

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 3,
      child: ExpansionTile(
        initiallyExpanded: false,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Text(
          'Apariencia',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.green.shade800,
          ),
        ),
        children: [
          const SizedBox(height: 4),
          const Text(
            'Tema de la aplicación',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),

          // RadioGroup para Claro / Oscuro / Automático
          RadioGroup<AppThemeMode>(
            groupValue: appearance.themeMode,
            onChanged: (mode) {
              if (mode != null) appearance.setThemeMode(mode);
            },
            child: Column(
              children: const [
                RadioListTile<AppThemeMode>(
                  value: AppThemeMode.system,
                  title: Text('Automático (según el sistema)'),
                  contentPadding: EdgeInsets.zero,
                ),
                RadioListTile<AppThemeMode>(
                  value: AppThemeMode.light,
                  title: Text('Tema claro'),
                  contentPadding: EdgeInsets.zero,
                ),
                RadioListTile<AppThemeMode>(
                  value: AppThemeMode.dark,
                  title: Text('Tema oscuro'),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 4),

          const Text(
            'Tamaño de texto',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),

          Row(
            children: [
              const Text('A-', style: TextStyle(fontSize: 12)),
              Expanded(
                child: Slider(
                  value: appearance.textScale,
                  min: 0.8,
                  max: 1.4,
                  divisions: 6,
                  label: '${(appearance.textScale * 100).round()}%',
                  onChanged: (value) {
                    appearance.setTextScale(value);
                  },
                ),
              ),
              const Text('A+', style: TextStyle(fontSize: 18)),
            ],
          ),

          const SizedBox(height: 4),
          Text(
            'Vista previa',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Este es un ejemplo de cómo se verá el texto en la app.',
            ),
          ),
        ],
      ),
    );
  }
}
