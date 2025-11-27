import 'package:flutter/services.dart';

class NativeDetectorService {
  static const platform = MethodChannel('com.example.reciclapp/detector');

  /// Verifica si el detector está listo
  Future<bool> isReady() async {
    try {
      final bool ready = await platform.invokeMethod('isReady');
      return ready;
    } catch (e) {
      print('Error verificando detector: $e');
      return false;
    }
  }

  /// Platform Channels: Detecta objetos desde una ruta de imagen
  Future<DetectionResult> detectFromPath(String imagePath) async {
    try {
      print('🔵 Llamando a detector nativo con: $imagePath');
      
      final Map<dynamic, dynamic> result = await platform.invokeMethod(
        'detectFromPath',
        {'path': imagePath},
      );

      final List<dynamic> detectionsRaw = result['detections'] ?? [];
      final int inferenceTime = result['inferenceTime'] ?? 0;

      print('✅ Detector nativo respondió:');
      print('   Detecciones: ${detectionsRaw.length}');
      print('   Tiempo: ${inferenceTime}ms');

      final detections = detectionsRaw.map((d) {
        return BoundingBox(
          className: d['className'] as String,
          confidence: (d['confidence'] as num).toDouble(),
          x1: (d['x1'] as num).toDouble(),
          y1: (d['y1'] as num).toDouble(),
          x2: (d['x2'] as num).toDouble(),
          y2: (d['y2'] as num).toDouble(),
          cx: (d['cx'] as num).toDouble(),
          cy: (d['cy'] as num).toDouble(),
          w: (d['w'] as num).toDouble(),
          h: (d['h'] as num).toDouble(),
        );
      }).toList();

      return DetectionResult(
        boxes: detections,
        inferenceTime: inferenceTime,
      );
    } on PlatformException catch (e) {
      print('❌ Error en detección nativa: ${e.message}');
      print('   Código: ${e.code}');
      print('   Detalles: ${e.details}');
      rethrow;
    }
  }
}

class BoundingBox {
  final String className;
  final double confidence;
  final double x1, y1, x2, y2;
  final double cx, cy, w, h;

  BoundingBox({
    required this.className,
    required this.confidence,
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    required this.cx,
    required this.cy,
    required this.w,
    required this.h,
  });
}

class DetectionResult {
  final List<BoundingBox> boxes;
  final int inferenceTime;

  DetectionResult({
    required this.boxes,
    required this.inferenceTime,
  });
}