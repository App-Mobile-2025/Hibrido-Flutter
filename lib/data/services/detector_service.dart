import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class BoundingBox {
  final double x1, y1, x2, y2;
  final double cx, cy, w, h;
  final double confidence;
  final int classIndex;
  final String className;

  BoundingBox({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    required this.cx,
    required this.cy,
    required this.w,
    required this.h,
    required this.confidence,
    required this.classIndex,
    required this.className,
  });
}

class DetectorService {
  static const String modelPath = 'assets/model.tflite';
  static const String labelsPath = 'assets/labels.txt';
  
  static const double confidenceThreshold = 0.1;
  static const double iouThreshold = 0.5;
  static const double inputMean = 0.0;
  static const double inputStd = 255.0;

  Interpreter? _interpreter;
  List<String> _labels = [];
  
  int tensorWidth = 0;
  int tensorHeight = 0;
  int numChannel = 0;
  int numElements = 0;

Future<void> setup() async {
  try {    
    _interpreter = await Interpreter.fromAsset(modelPath,
      options: InterpreterOptions()..threads = 2
    );

    final inputTensor = _interpreter!.getInputTensor(0);
    final outputTensor = _interpreter!.getOutputTensor(0);

    final inputShape = _interpreter!.getInputTensor(0).shape;
    final outputShape = _interpreter!.getOutputTensor(0).shape;
    
    tensorWidth = inputShape[1];
    tensorHeight = inputShape[2];
    
    // FORZAR los valores correctos
    if (outputShape[1] == 10 && outputShape[2] == 8400) {
      // El modelo está transpuesto: [1, clases+coords, detections]
      numChannel = outputShape[1];  // 10 (4 coords + 6 clases)
      numElements = outputShape[2]; // 8400
    } else if (outputShape[1] == 8400 && outputShape[2] == 10) {
      // Formato [1, detections, clases+coords]
      numElements = outputShape[1];
      numChannel = outputShape[2];
    } else {
      // Fallback
      numChannel = outputShape[1];
      numElements = outputShape[2];
    }

    final labelsData = await rootBundle.loadString(labelsPath);
    _labels = labelsData.split('\n').where((line) => line.isNotEmpty).toList();
    
  } catch (e, stack) {
    print('❌ ERROR: $e');
    print(stack);
    rethrow;
  }
}

 Future<DetectionResult> detect(img.Image image) async {
  if (_interpreter == null) {
    throw Exception('Detector no inicializado');
  }

  final stopwatch = Stopwatch()..start();

  // Redimensionar imagen
  final resizedImage = img.copyResize(
    image,
    width: tensorWidth,
    height: tensorHeight,
  );

  // Convertir a Float32List normalizado
  final inputBuffer = _imageToByteListFloat32(resizedImage);

  // Output buffer: [1, numChannel, numElements]
  final outputBuffer = Float32List(1 * numChannel * numElements);
  
  // Ejecutar inferencia
  try {
    _interpreter!.run(
      inputBuffer.reshape([1, tensorHeight, tensorWidth, 3]),
      outputBuffer.reshape([1, numChannel, numElements]),
    );
    print('✅ Inferencia ejecutada correctamente');
  } catch (e) {
    print('❌ ERROR en inferencia: $e');
    rethrow;
  }

  // Procesar resultados
  final boxes = _processOutput(outputBuffer);

  stopwatch.stop();

  return DetectionResult(
    boxes: boxes,
    inferenceTime: stopwatch.elapsedMilliseconds,
  );
}

Float32List _imageToByteListFloat32(img.Image image) {
  final convertedBytes = Float32List(tensorWidth * tensorHeight * 3);
  final buffer = Float32List.view(convertedBytes.buffer);
  
  int pixelIndex = 0;
  for (int y = 0; y < tensorHeight; y++) {
    for (int x = 0; x < tensorWidth; x++) {
      final pixel = image.getPixel(x, y);
      
      buffer[pixelIndex++] = (pixel.b - inputMean) / inputStd;  
      buffer[pixelIndex++] = (pixel.g - inputMean) / inputStd;
      buffer[pixelIndex++] = (pixel.r - inputMean) / inputStd;  
    }
  }
  
  return convertedBytes;
}

  List<BoundingBox> _processOutput(Float32List output) {
  final List<BoundingBox> boxes = [];

  double minVal = double.infinity;
  double maxVal = double.negativeInfinity;
  int nonZeroCount = 0;
  
  for (int i = 0; i < output.length; i++) {
    if (output[i] != 0.0) nonZeroCount++;
    if (output[i] < minVal) minVal = output[i];
    if (output[i] > maxVal) maxVal = output[i];
  }

  
  if (nonZeroCount == 0) {
    print('❌ TODOS los valores son 0.0 - El modelo no está funcionando');
    return [];
  }

  int candidatesFound = 0;

  for (int c = 0; c < numElements; c++) {
    double maxConf = -1.0;
    int maxIdx = -1;

    for (int j = 4; j < numChannel; j++) {
      final arrayIdx = c + numElements * j;
      if (output[arrayIdx] > maxConf) {
        maxConf = output[arrayIdx];
        maxIdx = j - 4;
      }
    }

// DEBUG: Mostrar primeros 5 elementos procesados
    if (c < 5) {
      print('   Elemento $c: maxConf=$maxConf, maxIdx=$maxIdx (${maxIdx < _labels.length ? _labels[maxIdx] : "?"})');
    }

   if (maxConf > confidenceThreshold) {
      candidatesFound++;
      
      final cx = output[c];
      final cy = output[c + numElements];
      final w = output[c + numElements * 2];
      final h = output[c + numElements * 3];

      final x1 = cx - (w / 2);
      final y1 = cy - (h / 2);
      final x2 = cx + (w / 2);
      final y2 = cy + (h / 2);

      if (x1 < 0 || x1 > 1 || y1 < 0 || y1 > 1 || 
          x2 < 0 || x2 > 1 || y2 < 0 || y2 > 1) {
        continue;
      }

      boxes.add(BoundingBox(
        x1: x1, y1: y1, x2: x2, y2: y2,
        cx: cx, cy: cy, w: w, h: h,
        confidence: maxConf,
        classIndex: maxIdx,
        className: _labels[maxIdx],
      ));
    }
  }

  return _applyNMS(boxes);
}

  List<BoundingBox> _applyNMS(List<BoundingBox> boxes) {
    if (boxes.isEmpty) return [];

    // Ordenar por confianza descendente
    boxes.sort((a, b) => b.confidence.compareTo(a.confidence));

    final selectedBoxes = <BoundingBox>[];

    while (boxes.isNotEmpty) {
      final first = boxes.removeAt(0);
      selectedBoxes.add(first);

      boxes.removeWhere((box) {
        final iou = _calculateIoU(first, box);
        return iou >= iouThreshold;
      });
    }

    return selectedBoxes;
  }

  double _calculateIoU(BoundingBox box1, BoundingBox box2) {
    final x1 = box1.x1 > box2.x1 ? box1.x1 : box2.x1;
    final y1 = box1.y1 > box2.y1 ? box1.y1 : box2.y1;
    final x2 = box1.x2 < box2.x2 ? box1.x2 : box2.x2;
    final y2 = box1.y2 < box2.y2 ? box1.y2 : box2.y2;

    final intersectionArea = (x2 - x1).clamp(0.0, double.infinity) * 
                             (y2 - y1).clamp(0.0, double.infinity);
    
    final box1Area = box1.w * box1.h;
    final box2Area = box2.w * box2.h;
    
    return intersectionArea / (box1Area + box2Area - intersectionArea);
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}

class DetectionResult {
  final List<BoundingBox> boxes;
  final int inferenceTime;

  DetectionResult({required this.boxes, required this.inferenceTime});
}