import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:reciclapp/ui/configuracion/provider/language_provider.dart';

class LanguageConfigSection extends StatelessWidget {
  const LanguageConfigSection({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().language;

    return Opacity(
      opacity: 0.6, // se ve medio deshabilitado
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 3,
        child: ExpansionTile(
          initiallyExpanded: false,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),

          // Cuando el usuario toca para expandir, mostramos el SnackBar
          onExpansionChanged: (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Esta funcionalidad estará disponible en la próxima actualización.',
                ),
                duration: Duration(seconds: 2),
              ),
            );
          },
          title: Row(
            children: [
              const Icon(Icons.lock, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Idioma de la aplicación — Disponible en la próxima actualización',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade800,
                  ),
                ),
              ),
            ],
          ),

          children: [
            RadioGroup<AppLanguage>(
              groupValue: lang,
              onChanged: (_) {},
              child: Column(
                children: const [
                  LanguageTile(
                    value: AppLanguage.es,
                    description: 'Español (Argentina)',
                  ),
                  Divider(height: 0),
                  LanguageTile(
                    value: AppLanguage.en,
                    description: 'English (US)',
                  ),
                  Divider(height: 0),
                  LanguageTile(
                    value: AppLanguage.pt,
                    description: 'Português (BR)',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Próximamente vas a poder cambiar el idioma de toda la app desde acá.',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class LanguageTile extends StatelessWidget {
  final AppLanguage value;
  final String description;

  const LanguageTile({
    super.key,
    required this.value,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<AppLanguage>(
      value: value,
      //Deshabilitado: no se puede tocar
      groupValue: null,
      onChanged: null,
      title: Text(
        '${value.flag}  ${value.label}',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(description),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
    );
  }
}
