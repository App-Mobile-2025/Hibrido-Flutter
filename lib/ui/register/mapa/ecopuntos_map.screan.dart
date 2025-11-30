import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import 'ecopuntos_ba.dart';

class EcopuntoMapScreen extends StatefulWidget {
  const EcopuntoMapScreen({super.key});

  @override
  State<EcopuntoMapScreen> createState() => _EcopuntoMapScreenState();
}

class _EcopuntoMapScreenState extends State<EcopuntoMapScreen> {
  GoogleMapController? _mapController;

  Ecopunto? _seleccionado;
  String? _direccionSeleccionada;

  bool _cargandoUbicacion = false;

  // ==========================
  //  REVERSE GEOCODING
  // ==========================
  Future<String> _obtenerDireccion(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isEmpty) {
        return "Dirección no disponible";
      }

      final place = placemarks.first;

      final calle = place.street; // Av. Cabildo
      final numero = place.subThoroughfare; // 4520
      final barrio = place.subLocality; // Palermo, etc.
      final ciudad = place.locality; // CABA
      final provincia = place.administrativeArea; // Buenos Aires

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

      if (partes.isEmpty) {
        return "Dirección no disponible";
      }

      return partes.join(", ");
    } catch (_) {
      return "Dirección no disponible";
    }
  }

  // ==========================
  //  MI UBICACIÓN
  // ==========================
  Future<void> _irAMiUbicacion() async {
    setState(() {
      _cargandoUbicacion = true;
      _direccionSeleccionada = null;
    });

    // GPS activado
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _cargandoUbicacion = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor activá el GPS para usar tu ubicación'),
        ),
      );
      return;
    }

    // Permisos
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _cargandoUbicacion = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Se necesita permiso de ubicación')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _cargandoUbicacion = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'El permiso de ubicación está bloqueado.\nHabilitalo desde Ajustes.',
          ),
        ),
      );
      return;
    }

    // Posición actual
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final userLatLng = LatLng(pos.latitude, pos.longitude);

    // Mover cámara
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(userLatLng, 16),
      );
    }

    // Dirección real
    final direccion = await _obtenerDireccion(pos.latitude, pos.longitude);

    if (!mounted) return;

    setState(() {
      _seleccionado = Ecopunto(
        'Ubicación actual',
        pos.latitude,
        pos.longitude,
      );
      _direccionSeleccionada = direccion;
      _cargandoUbicacion = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final initial = EcopuntosBA.lista.first;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Elegir Ecopunto'),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(initial.lat, initial.lng),
              zoom: 11,
            ),
            onMapCreated: (c) => _mapController = c,
            myLocationEnabled: true,
            myLocationButtonEnabled: false, // usamos botón propio
            zoomControlsEnabled: true,
            padding: _seleccionado != null
                ? const EdgeInsets.only(right: 8, bottom: 160)
                : const EdgeInsets.only(right: 8, bottom: 80),
            markers: EcopuntosBA.lista
                .map(
                  (e) => Marker(
                    markerId: MarkerId(e.nombre),
                    position: LatLng(e.lat, e.lng),
                    infoWindow: const InfoWindow(),
                    onTap: () async {
                      setState(() {
                        _seleccionado = e;
                        _direccionSeleccionada = null;
                      });

                      final dir =
                          await _obtenerDireccion(e.lat, e.lng);

                      if (!mounted) return;
                      setState(() {
                        _direccionSeleccionada = dir;
                      });
                    },
                  ),
                )
                .toSet(),
          ),

          // Tarjeta inferior con el punto seleccionado
          if (_seleccionado != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _seleccionado!.nombre,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    if (_direccionSeleccionada != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _direccionSeleccionada!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],

                    const SizedBox(height: 4),
                    Text(
                      '(${_seleccionado!.lat.toStringAsFixed(5)}, '
                      '${_seleccionado!.lng.toStringAsFixed(5)})',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context, _seleccionado);
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Usar este punto'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // FAB "Mi ubicación", más chico y ajustado
          Positioned(
            right: 14,
            bottom: _seleccionado != null ? 255 : 174,
            child: FloatingActionButton.small(
              onPressed: _cargandoUbicacion ? null : _irAMiUbicacion,
              backgroundColor: Colors.green,
              child: _cargandoUbicacion
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.my_location, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
