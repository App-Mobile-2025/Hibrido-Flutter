import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reciclapp/ui/register/confirmacion_screen.dart';

class RegistrarStep2Screen extends StatefulWidget {
  final String ecopunto;
  final List<String> materiales;

  const RegistrarStep2Screen({
    super.key,
    required this.ecopunto,
    required this.materiales,
  });

  @override
  State<RegistrarStep2Screen> createState() => _RegistrarStep2ScreenState();
}

class _RegistrarStep2ScreenState extends State<RegistrarStep2Screen> {
  final _notaController = TextEditingController();
  final _etiquetasController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  File? _imagenSeleccionada;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  @override
  void dispose() {
    _notaController.dispose();
    _etiquetasController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarDeGaleria() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _imagenSeleccionada = File(image.path);
        });
      }
    } catch (e) {
      _mostrarError('Error al seleccionar imagen: $e');
    }
  }

  Future<void> _tomarFoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _imagenSeleccionada = File(image.path);
        });
      }
    } catch (e) {
      _mostrarError('Error al tomar foto: $e');
    }
  }

  Future<void> _confirmarReciclaje() async {
    if (_imagenSeleccionada == null) {
      _mostrarError('Por favor selecciona una imagen de evidencia');
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _mostrarError('Usuario no autenticado');
        return;
      }

      // Subir imagen a Firebase Storage
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('evidencias')
          .child(user.uid)
          .child(fileName);

      final uploadTask = storageRef.putFile(_imagenSeleccionada!);

      uploadTask.snapshotEvents.listen((snapshot) {
        setState(() {
          _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
        });
      });

      await uploadTask;
      final imageUrl = await storageRef.getDownloadURL();

      // Procesar etiquetas
      final etiquetas = _etiquetasController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      // Calcular puntos (ejemplo simple: 10 puntos por material)
      final puntos = widget.materiales.length * 10;

      // Guardar en Firestore
      await FirebaseFirestore.instance.collection('reciclajes').add({
        'uid': user.uid,
        'materiales': widget.materiales,
        'ecopunto': widget.ecopunto,
        'evidenciaUrl': imageUrl,
        'nota': _notaController.text.trim(),
        'tags': etiquetas,
        'puntos': puntos,
        'estado': 'pendiente',
        'confirmedAt': FieldValue.serverTimestamp(),
      });

      // Actualizar puntos del usuario
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'puntos': FieldValue.increment(puntos),
        'lastConfirmedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        // Navegar a confirmación
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ConfirmacionScreen(puntosGanados: puntos),
          ),
        );
      }
    } catch (e) {
      _mostrarError('Error al confirmar reciclaje: $e');
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        title: const Text('Registrar Reciclaje (2/2)'),
        backgroundColor: Colors.green,
      ),
      body: _isUploading
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    value: _uploadProgress,
                    strokeWidth: 6,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Subiendo evidencia... ${(_uploadProgress * 100).toInt()}%',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Resumen del paso anterior
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: Colors.green, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              widget.ecopunto,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: widget.materiales.map((material) {
                            return Chip(
                              label: Text(material),
                              backgroundColor: Colors.white,
                              side: BorderSide(color: Colors.green.shade200),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Evidencia fotográfica',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (_imagenSeleccionada != null)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _imagenSeleccionada!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () {
                              setState(() => _imagenSeleccionada = null);
                            },
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _OpcionFoto(
                          icon: Icons.photo_library,
                          label: 'Seleccionar de galería',
                          color: Colors.blue,
                          onTap: _seleccionarDeGaleria,
                        ),
                        const SizedBox(height: 12),
                        _OpcionFoto(
                          icon: Icons.camera_alt,
                          label: 'Tomar foto',
                          color: Colors.orange,
                          onTap: _tomarFoto,
                        ),
                      ],
                    ),

                  const SizedBox(height: 24),

                  const Text(
                    'Notas de entrega',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notaController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText:
                          'Ej: 5 botellas de plástico, 3 latas de aluminio...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.green.shade100),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.green, width: 2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Etiquetas (opcional)',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _etiquetasController,
                    decoration: InputDecoration(
                      hintText: 'Ej: hogar, oficina, escuela (separadas por comas)',
                      prefixIcon: const Icon(Icons.label, color: Colors.green),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.green.shade100),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.green, width: 2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Colors.green),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'ATRÁS',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _confirmarReciclaje,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle),
                              SizedBox(width: 8),
                              Text(
                                'CONFIRMAR',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

class _OpcionFoto extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String? badge;
  final VoidCallback onTap;

  const _OpcionFoto({
    required this.icon,
    required this.label,
    required this.color,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
