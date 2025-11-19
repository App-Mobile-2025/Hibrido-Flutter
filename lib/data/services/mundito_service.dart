import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ai/firebase_ai.dart';

class MunditoService {
  final FirebaseAuth _auth;

  MunditoService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  // IA: Gemini 2.5 Flash con Firebase AI
  Future<String> askMundito(String question) async {
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

      final ai = FirebaseAI.vertexAI(auth: _auth);

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
}
