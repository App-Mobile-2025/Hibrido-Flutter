import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reciclapp/ui/camera/camera_screen.dart';
import 'package:reciclapp/ui/register/confirmacion_screen.dart';
import 'package:geocoding/geocoding.dart';

/// Clase interna para manejar coordenadas
class _Coord {
  final double lat;
  final double lng;
  _Coord(this.lat, this.lng);
}

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

  // ==========================
  //   HELPERS DE UBICACIÓN
  // ==========================

  /// Extrae (lat, lng) de algo tipo:
  /// "Ecopunto San Telmo (-34.62170, -58.37130)"
  _Coord? _parseCoordsFromEcopunto(String ecopunto) {
    final regex = RegExp(r'\((-?\d+\.?\d*),\s*(-?\d+\.?\d*)\)');
    final match = regex.firstMatch(ecopunto);
    if (match == null) return null;

    final lat = double.tryParse(match.group(1)!);
    final lng = double.tryParse(match.group(2)!);
    if (lat == null || lng == null) return null;

    return _Coord(lat, lng);
  }

  Future<Placemark?> _obtenerDireccionDesdeCoords(_Coord coord) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        coord.lat,
        coord.lng,
      );
      if (placemarks.isEmpty) return null;
      return placemarks.first;
    } catch (e) {
      debugPrint('Error en geocoding: $e');
      return null;
    }
  }

  // ==========================
  //   MANEJO DE IMÁGENES
  // ==========================

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

  void _abrirCamaraIA() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CameraScreen()),
    );
  }

  // ==========================
  //   CONFIRMAR RECICLAJE
  // ==========================

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

    debugPrint('[RECICLAJE] Usuario: ${user.uid}');

    // SUBIR IMAGEN A STORAGE
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('evidencias')
        .child(user.uid)
        .child(fileName);

    debugPrint('[RECICLAJE] Subiendo imagen: $fileName');

    final uploadTask = storageRef.putFile(_imagenSeleccionada!);

    uploadTask.snapshotEvents.listen((snapshot) {
      if (!mounted) return;
      setState(() {
        _uploadProgress =
            snapshot.bytesTransferred / snapshot.totalBytes;
      });
    });

    await uploadTask;
    final imageUrl = await storageRef.getDownloadURL();

    debugPrint('[RECICLAJE] Imagen subida. URL: $imageUrl');

    // PROCESAR ETIQUETAS Y PUNTOS
    final etiquetas = _etiquetasController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final puntos = widget.materiales.length * 10;
    debugPrint('[RECICLAJE] Materiales: ${widget.materiales}');
    debugPrint('[RECICLAJE] Puntos calculados: $puntos');

    // INFO BÁSICA DEL ECOPUNTO (nombre + coords si se pueden parsear)
    final coord = _parseCoordsFromEcopunto(widget.ecopunto);
    String nombreEcopunto = widget.ecopunto;
    final idxParentesis = widget.ecopunto.indexOf('(');
    if (idxParentesis > 0) {
      nombreEcopunto =
          widget.ecopunto.substring(0, idxParentesis).trim();
    }

    // GUARDAR DOCUMENTO BÁSICO EN FIRESTORE (SIN GEOCODING TODAVÍA)
    debugPrint('[RECICLAJE] Guardando documento básico en Firestore...');

    final docRef =
        await FirebaseFirestore.instance.collection('reciclajes').add({
      'uid': user.uid,
      'materiales': widget.materiales,
      'ecopuntoNombre': nombreEcopunto,
      'ecopunto': widget.ecopunto,
      'lat': coord?.lat,
      'lng': coord?.lng,
      'evidenciaUrl': imageUrl,
      'nota': _notaController.text.trim(),
      'tags': etiquetas,
      'puntos': puntos,
      'estado': 'pendiente',
      'confirmedAt': FieldValue.serverTimestamp(),
    });

    debugPrint('[RECICLAJE] Documento creado con ID: ${docRef.id}');

    // ACTUALIZAR PUNTOS DEL USUARIO
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({
      'puntos': FieldValue.increment(puntos),
      'lastConfirmedAt': FieldValue.serverTimestamp(),
    });

    debugPrint('[RECICLAJE] Puntos del usuario actualizados');

    // GEOCODING SOLO PARA direccionCompleta
    if (coord != null) {
      debugPrint(
          '[RECICLAJE] Obteniendo dirección para ${coord.lat}, ${coord.lng}');

      try {
        final place = await _obtenerDireccionDesdeCoords(coord);
        if (place != null) {
          String? direccionCompleta;

          final calle = place.street;
          final numero = place.subThoroughfare;
          final barrio = place.subLocality;
          final ciudad = place.locality;
          final provincia = place.administrativeArea;

          final partes = <String>[];
          if (calle != null && calle.trim().isNotEmpty) {
            if (numero != null && numero.trim().isNotEmpty) {
              partes.add("$calle $numero");
            } else {
              partes.add(calle);
            }
          }
          if (barrio != null && barrio.trim().isNotEmpty) {
            partes.add(barrio);
          }
          if (ciudad != null && ciudad.trim().isNotEmpty) {
            partes.add(ciudad);
          }
          if (provincia != null && provincia.trim().isNotEmpty) {
            partes.add(provincia);
          }
          if (partes.isNotEmpty) {
            direccionCompleta = partes.join(", ");
          }

          debugPrint(
              '[RECICLAJE] Dirección obtenida: $direccionCompleta');

          // SOLO guardamos la dirección completa
          await docRef.update({
            'direccionCompleta': direccionCompleta,
          });

          debugPrint(
              '[RECICLAJE] Documento actualizado con direccionCompleta');
        }
      } catch (e) {
        debugPrint('[RECICLAJE] Error en geocoding (no crítico): $e');
      }
    }

    // 7) NAVEGAR A CONFIRMACIÓN
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ConfirmacionScreen(puntosGanados: puntos),
        ),
      );
    }
  } catch (e, st) {
    debugPrint('[RECICLAJE] Error al confirmar: $e');
    debugPrint('[RECICLAJE] Stack: $st');
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

  // ==========================
  //   UI
  // ==========================

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
                            const Icon(
                              Icons.location_on,
                              color: Colors.green,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.ecopunto,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
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
                              side: BorderSide(
                                color: Colors.green.shade200,
                              ),
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
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () {
                              setState(
                                () => _imagenSeleccionada = null,
                              );
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
                        borderSide: BorderSide(
                          color: Colors.green.shade100,
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide:
                            BorderSide(color: Colors.green, width: 2),
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
                      hintText:
                          'Ej: hogar, oficina, escuela (separadas por comas)',
                      prefixIcon: const Icon(
                        Icons.label,
                        color: Colors.green,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.green.shade100,
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide:
                            BorderSide(color: Colors.green, width: 2),
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
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
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
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
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
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
