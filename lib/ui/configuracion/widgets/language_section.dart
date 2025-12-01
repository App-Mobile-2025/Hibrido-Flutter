import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:reciclapp/ui/configuracion/language_provider.dart';

class LanguageConfigSection extends StatelessWidget {
  const LanguageConfigSection({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().language;

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
          'Idioma de la aplicación',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.green.shade800,
          ),
        ),
        children: [
          // ⚠️ Nuevo API: RadioGroup (si tu versión de Flutter lo trae)
          RadioGroup<AppLanguage>(
            groupValue: lang,
            onChanged: (value) {
              if (value != null) {
                context.read<LanguageProvider>().setLanguage(value);
              }
            },
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
            'El idioma se aplicará en todas las pantallas compatibles. '
            'Algunas secciones pueden seguir apareciendo en español si aún no fueron traducidas.',
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ],
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
      // groupValue y onChanged los maneja RadioGroup
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
