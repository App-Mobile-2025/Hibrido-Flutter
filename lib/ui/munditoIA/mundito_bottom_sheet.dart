import 'package:flutter/material.dart';
import 'package:reciclapp/data/services/mundito_service.dart'; // ajustá el path si hace falta

class MunditoBottomSheet extends StatefulWidget {
  const MunditoBottomSheet({super.key});

  @override
  State<MunditoBottomSheet> createState() => _MunditoBottomSheetState();
}

class _MunditoBottomSheetState extends State<MunditoBottomSheet> {
  final TextEditingController _questionCtrl = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final DraggableScrollableController _dragController =
      DraggableScrollableController();

  final MunditoService _munditoService = MunditoService();

  bool _loading = false;

  // Historial compartido entre TODAS las aperturas de Mundito
  static final List<_ChatMessage> _history = [];

  // referencia práctica al historial
  late final List<_ChatMessage> _messages;

  final List<String> _faqs = const [
    '¿Cómo registro un residuo en la app?',
    '¿Dónde veo los ecopuntos cercanos?',
    '¿Cómo canjeo mis puntos por premios?',
    '¿Cómo edito mis datos de perfil?',
    'Tengo un problema al subir una evidencia',
  ];

  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  @override
  void initState() {
    super.initState();

    _messages = _history;

    // Primer saludo
    if (_messages.isEmpty) {
      _messages.add(
        const _ChatMessage(
          text: 'Hola, soy Mundito 🌎. ¿En qué te ayudo con el reciclaje hoy?',
          fromUser: false,
        ),
      );
    }

    // Al abrir, scrolleo al final
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _questionCtrl.dispose();
    _scrollController.dispose();
    _dragController.dispose();
    super.dispose();
  }

  Future<void> _handleQuestion(String text) async {
    final query = text.trim();
    if (query.isEmpty) return;

    _safeSetState(() {
      _loading = true;
      _messages.add(
        _ChatMessage(
          text: query,
          fromUser: true,
        ),
      );
    });

    // Cuando el usuario manda una pregunta, agrandamos el sheet casi a full
    try {
    _dragController.animateTo(
      0.99,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  } catch (_) {}


    _scrollToBottom();

    try {
      final resp = await _munditoService.askMundito(query);

      if (!mounted) return;

      _safeSetState(() {
        _messages.add(
          _ChatMessage(
            text: resp,
            fromUser: false,
          ),
        );
      });

      _scrollToBottom();
    } finally {
      if (!mounted) return;
      _safeSetState(() => _loading = false);
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return SafeArea(
    top: false,          // dejamos que llegue arriba del todo
    child: DraggableScrollableSheet(
      controller: _dragController,
      initialChildSize: 0.80,
      minChildSize: 0.55,
      maxChildSize: 0.98,
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

              // 🟢 Zona de chat (gran parte de la pantalla)
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
                      // Lista de mensajes
                      ListView.builder(
                        controller: _scrollController,
                        itemCount: _messages.length,
                        padding: const EdgeInsets.only(bottom: 16, top: 8),
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final isUser = msg.fromUser;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: isUser
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!isUser) ...[
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: const Color(0xFF064E3B),
                                    backgroundImage: const AssetImage(
                                      'assets/mundito_icon_v2.png',
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isUser
                                          ? const Color(0xFF16A34A)
                                          : const Color(0xFF064E3B),
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(16),
                                        topRight: const Radius.circular(16),
                                        bottomLeft: Radius.circular(
                                          isUser ? 16 : 4,
                                        ),
                                        bottomRight: Radius.circular(
                                          isUser ? 4 : 16,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      msg.text,
                                      style: TextStyle(
                                        color: isUser
                                            ? Colors.white
                                            : const Color(0xFFC8FACC),
                                        fontSize: 14,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ),
                                if (isUser) const SizedBox(width: 4),
                              ],
                            ),
                          );
                        },
                      ),

                      // Overlay "pensando"
                      if (_loading)
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            margin: const EdgeInsets.only(top: 4),
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
                                      Colors.white,
                                    ),
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

              const SizedBox(height: 10),

              //  Campo de pregunta (debajo del chat)
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

              // Botón debajo del campo de texto
              SizedBox(
                width: double.infinity,
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
                    _loading ? 'Pensando...' : 'Preguntar a Mundito',
                  ),
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
        );
      },
    ));
  }
}

// Modelo de mensaje
class _ChatMessage {
  final String text;
  final bool fromUser;

  const _ChatMessage({
    required this.text,
    required this.fromUser,
  });
}
