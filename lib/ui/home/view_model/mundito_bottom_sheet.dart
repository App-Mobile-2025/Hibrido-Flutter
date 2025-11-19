import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ai/firebase_ai.dart';

class MunditoBottomSheet extends StatefulWidget {
  const MunditoBottomSheet({super.key});

  @override
  State<MunditoBottomSheet> createState() => _MunditoBottomSheetState();
}

class _MunditoBottomSheetState extends State<MunditoBottomSheet> {
  final TextEditingController _questionCtrl = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _answer =
      'Hola, soy Mundito 🌎. ¿En qué te ayudo con el reciclaje hoy?';
  bool _loading = false;

  final List<String> _faqs = const [
    '¿Cómo registro un residuo en la app?',
    '¿Dónde veo los ecopuntos cercanos?',
    '¿Cómo canjeo mis puntos por premios?',
    '¿Cómo edito mis datos de perfil?',
    'Tengo un problema al subir una evidencia',
  ];

  /// Helper para evitar repetir mounted checks
  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  @override
  void dispose() {
    _questionCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleQuestion(String text) async {
    final query = text.trim();
    if (query.isEmpty) return;

    _safeSetState(() {
      _loading = true;
      //_answer = 'Generando sugerencia ecológica...\n\nMundito está pensando 🤔';
    });

    try {
      final resp = await _askMundito(query);

      if (!mounted) return;

      _safeSetState(() => _answer = resp);

      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    } finally {
      if (!mounted) return;
      _safeSetState(() => _loading = false);
    }
  }

  // IA: Gemini 2.5 Flash con Firebase AI
  Future<String> _askMundito(String question) async {
    if (question.trim().isEmpty) {
      return 'Escribí una pregunta para que pueda ayudarte 🌎';
    }

    try {
      const systemPrompt = '''
Sos Mundito, el asistente ecológico de la app ReciclApp para Argentina.
Tu estilo es:
- Claro, cortito y en español neutro tirando a argentino.
- Amable y motivador, pero sin ser excesivamente formal.
- Siempre das tips prácticos sobre reciclaje, separación de residuos, ecopuntos y canjes.

Si la pregunta no tiene nada que ver con reciclaje, medioambiente o el uso de la app,
respondé igual pero tratando de llevar la respuesta a un enfoque ecológico o de uso de ReciclApp.
''';

      final userPrompt = '''
Usuario: $question

Respondé como Mundito con un párrafo corto y, si podés, con 1 o 2 bullets simples.
''';

      final fullPrompt = '$systemPrompt\n\n$userPrompt';

      final ai = FirebaseAI.vertexAI(auth: FirebaseAuth.instance);

      final model = ai.generativeModel(
        model: 'gemini-2.5-flash',
      );

      final response = await model.generateContent(
        [Content.text(fullPrompt)],
      );

      final text = response.text;

      if (text == null || text.trim().isEmpty) {
        return 'Por ahora no tengo datos suficientes para responder eso 🌎. Probá reformular la pregunta.';
      }

      return text.trim();
    } catch (e) {
      return 'Ups, tuve un problema al conectarme con la IA 😕. Verificá tu conexión y probá de nuevo.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.80,
      minChildSize: 0.50,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF042F2E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            children: [
              // Handle del sheet
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),

              // Header Mundito
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 95,
                    height: 74,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/mundito_icon_v2.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mundito - Asistente Eco IA',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFC8FACC),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Te ayudo con reciclaje, ecopuntos y canjes dentro de ReciclApp.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFFB6E3C8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Chips de preguntas rápidas
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Preguntas rápidas',
                  style: tema.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF9FE3B0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _faqs.map((q) {
                  return ActionChip(
                    label: Text(
                      q,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: const Color(0xFF064E3B),
                    labelStyle: const TextStyle(color: Colors.white),
                    onPressed: _loading ? null : () => _handleQuestion(q),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Campo de pregunta
              TextField(
                controller: _questionCtrl,
                maxLines: 3,
                minLines: 1,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF022C22),
                  hintText: 'Escribí tu pregunta para Mundito...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Colors.greenAccent),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Botón enviar
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _loading
                          ? null
                          : () async {
                              final q = _questionCtrl.text;
                              _questionCtrl.clear();
                              await _handleQuestion(q);
                            },
                      icon: const Icon(Icons.send),
                      label: Text(
                          _loading ? 'Pensando...' : 'Preguntar a Mundito'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Respuesta (burbuja + overlay de carga)
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF022C22),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Stack(
                    children: [
                      // Contenido scrollable con burbuja
                      SingleChildScrollView(
                        controller: _scrollController,
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(right: 40),
                            decoration: BoxDecoration(
                              color: const Color(0xFF064E3B),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: SelectableText(
                              _answer,
                              style: const TextStyle(
                                color: Color(0xFFC8FACC),
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Overlay de "pensando"
                      if (_loading)
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            margin: const EdgeInsets.only(top: 10),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.40),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Mundito está pensando...',
                                  style: TextStyle(
                                    color: Color(0xFFC8FACC),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
