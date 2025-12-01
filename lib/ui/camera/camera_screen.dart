import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reciclapp/data/services/native_detector_service.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  final NativeDetectorService _detector = NativeDetectorService(); 
  
  List<BoundingBox> _currentDetections = [];
  bool _isAnalyzing = false;
  bool _isCameraInitialized = false;
  
  Position? _lastPosition;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
    _getLocation();
    _checkDetectorReady(); 
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _checkDetectorReady() async {
    final ready = await _detector.isReady();
    if (ready) {
      print('✅ Detector nativo listo');
    } else {
      print('⏳ Detector nativo inicializando...');
      // Reintentar después de 2 segundos
      Future.delayed(const Duration(seconds: 2), _checkDetectorReady);
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      
      if (cameras.isEmpty) {
        debugPrint('No hay cámaras disponibles');
        return;
      }

      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      // Configuración SIMPLE de cámara
      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (!mounted) return;

      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      debugPrint('❌ Error inicializando cámara: $e');
      _showSnackBar('Error al iniciar la cámara');
    }
  }

  Future<void> _detectNow() async {
    if (_isAnalyzing || !_isCameraInitialized) return;

    setState(() {
      _isAnalyzing = true;
      _currentDetections = [];
    });

    try {
      // Capturar foto
      final XFile photo = await _cameraController!.takePicture();
      
      debugPrint('✅ Foto capturada: ${photo.path}');

      // Cargar imagen
      final bytes = await photo.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        debugPrint('❌ Error decodificando imagen');
        _showSnackBar('Error al procesar imagen');
        setState(() => _isAnalyzing = false);
        return;
      }

      debugPrint('✅ Imagen decodificada: ${image.width}x${image.height}');

      // Llamar al detector NATIVO
      final result = await _detector.detectFromPath(photo.path);

      if (mounted) {
        setState(() {
          _currentDetections = result.boxes;
        });

        if (_currentDetections.isEmpty) {
          _showSnackBar('No se detectaron objetos. Intenta de nuevo.');
        } else {
          _showSnackBar('✅ ${_currentDetections.length} objeto(s) detectado(s)!');
        }
      }
    } catch (e) {
      debugPrint('❌ Error detectando: $e');
      _showSnackBar('Error al detectar: $e');
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  Future<void> _captureAndSave() async {
    if (_currentDetections.isEmpty) {
      _showSnackBar('Primero detecta objetos');
      return;
    }

    try {
      _showSnackBar('Guardando imagen...');

      final XFile photo = await _cameraController!.takePicture();
      final bytes = await photo.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) return;

      final imageWithBoxes = _drawDetections(image, _currentDetections);
      final file = await _saveImage(imageWithBoxes);
      await _uploadAndSaveToFirebase(file);

      _showSnackBar('✅ Imagen guardada correctamente');
      
      setState(() => _currentDetections = []);
    } catch (e) {
      debugPrint('Error guardando: $e');
      _showSnackBar('❌ Error al guardar imagen');
    }
  }

  img.Image _drawDetections(img.Image image, List<BoundingBox> detections) {
    for (var box in detections) {
      final x1 = (box.x1 * image.width).toInt();
      final y1 = (box.y1 * image.height).toInt();
      final x2 = (box.x2 * image.width).toInt();
      final y2 = (box.y2 * image.height).toInt();

      img.drawRect(
        image,
        x1: x1,
        y1: y1,
        x2: x2,
        y2: y2,
        color: img.ColorRgb8(0, 255, 0),
        thickness: 3,
      );

      img.drawString(
        image,
        '${box.className} ${(box.confidence * 100).toStringAsFixed(0)}%',
        font: img.arial24,
        x: x1,
        y: (y1 - 30).clamp(0, image.height - 1),
        color: img.ColorRgb8(255, 255, 255),
      );
    }

    return image;
  }

  Future<File> _saveImage(img.Image image) async {
    final directory = await getApplicationDocumentsDirectory();
    final capturesDir = Directory('${directory.path}/Capturas');
    
    if (!await capturesDir.exists()) {
      await capturesDir.create(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${capturesDir.path}/captura_$timestamp.jpg');
    
    await file.writeAsBytes(img.encodeJpg(image, quality: 90));
    return file;
  }

  Future<void> _uploadAndSaveToFirebase(File imageFile) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    final deteccionesInfo = _currentDetections.map((box) => {
      'label': box.className,
      'confidence': box.confidence,
      'x1': box.x1,
      'y1': box.y1,
      'x2': box.x2,
      'y2': box.y2,
    }).toList();

    final clasificacion = _clasificarDetecciones(_currentDetections);

    await FirebaseFirestore.instance.collection('evidencias').add({
      'uid': user.uid,  
      'imagePath': imageFile.path,
      'detecciones': deteccionesInfo,
      'timestamp': FieldValue.serverTimestamp(),
      'clasificacion': clasificacion,
      'latitud': _lastPosition?.latitude,
      'longitud': _lastPosition?.longitude,
    });
  }

  String _clasificarDetecciones(List<BoundingBox> detections) {
    final labels = detections.map((d) => d.className.toLowerCase()).toList();

    if (labels.any((l) => l.contains('glass') || l.contains('bottle'))) {
      return 'reciclable';
    }
    if (labels.any((l) => l.contains('plastic'))) {
      return 'reciclable';
    }
    if (labels.any((l) => l.contains('papel') || l.contains('cardboard'))) {
      return 'reciclable';
    }
    if (labels.any((l) => l.contains('metal') || l.contains('can'))) {
      return 'reciclable';
    }
    if (labels.any((l) => l.contains('organic') || l.contains('food'))) {
      return 'organico';
    }

    return 'no_reciclable';
  }

  Future<void> _getLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      
      _lastPosition = await Geolocator.getCurrentPosition();
    } catch (e) {
      debugPrint('Error obteniendo ubicación: $e');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

@override
Widget build(BuildContext context) {
  if (!_isCameraInitialized) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Iniciando cámara...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  return Scaffold(
    backgroundColor: Colors.black,
    body: Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: AspectRatio(
            aspectRatio: 1 / _cameraController!.value.aspectRatio,
            child: CameraPreview(_cameraController!),
          ),
        ),

        // Overlay con detecciones
        if (_currentDetections.isNotEmpty)
          Positioned.fill(
            child: CustomPaint(
              painter: SimpleBoundingBoxPainter(
                detections: _currentDetections,
              ),
            ),
          ),

        // Header, boton a la izq, contador a la der
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Botón 
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const Spacer(),
                // Contador 
                if (_currentDetections.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentDetections.length} detectado(s)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Botones
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Botón DETECTAR
              GestureDetector(
                onTap: _isAnalyzing ? null : _detectNow,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isAnalyzing ? Colors.grey : Colors.blue,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.5),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: _isAnalyzing
                      ? const Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Icon(
                          Icons.search,
                          size: 40,
                          color: Colors.white,
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isAnalyzing ? 'Analizando...' : 'DETECTAR',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Botón GUARDAR
              if (_currentDetections.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: _captureAndSave,
                  icon: const Icon(Icons.save),
                  label: const Text('GUARDAR CAPTURA'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}
}

class SimpleBoundingBoxPainter extends CustomPainter {
  final List<BoundingBox> detections;

  SimpleBoundingBoxPainter({required this.detections});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.greenAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    for (var box in detections) {
      final rect = Rect.fromLTRB(
        box.x1 * size.width,
        box.y1 * size.height,
        box.x2 * size.width,
        box.y2 * size.height,
      );

      canvas.drawRect(rect, paint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: '${box.className} ${(box.confidence * 100).toInt()}%',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            backgroundColor: Colors.black87,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(rect.left, (rect.top - 30).clamp(0, size.height)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}