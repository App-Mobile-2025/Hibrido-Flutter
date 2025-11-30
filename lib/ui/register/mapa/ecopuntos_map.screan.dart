import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'ecopuntos_ba.dart';

class EcopuntoMapScreen extends StatefulWidget {
  const EcopuntoMapScreen({super.key});

  @override
  State<EcopuntoMapScreen> createState() => _EcopuntoMapScreenState();
}

class _EcopuntoMapScreenState extends State<EcopuntoMapScreen> {
  GoogleMapController? _mapController;
  Ecopunto? _seleccionado;
  bool _cargandoUbicacion = false;

  Future<void> _irAMiUbicacion() async {
    setState(() {
      _cargandoUbicacion = true;
    });

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
            'El permiso de ubicación está bloqueado. Habilitalo desde Ajustes.',
          ),
        ),
      );
      return;
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final userLatLng = LatLng(pos.latitude, pos.longitude);

    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(userLatLng, 16),
      );
    }

    setState(() {
      _seleccionado = Ecopunto(
        'Ubicación actual',
        pos.latitude,
        pos.longitude,
      );
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
            markers: EcopuntosBA.lista
                .map(
                  (e) => Marker(
                    markerId: MarkerId(e.nombre),
                    position: LatLng(e.lat, e.lng),
                    infoWindow: InfoWindow(title: e.nombre),
                    onTap: () {
                      setState(() {
                        _seleccionado = e;
                      });
                    },
                  ),
                )
                .toSet(),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            // Esto mueve + y - hacia arriba cuando hay tarjeta abajo
            padding: _seleccionado != null
                ? const EdgeInsets.only(bottom: 130)
                : EdgeInsets.zero,
          ),

          // Tarjeta inferior con punto seleccionado
          if (_seleccionado != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
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
                    const SizedBox(height: 4),
                    Text(
                      '(${_seleccionado!.lat.toStringAsFixed(5)}, '
                      '${_seleccionado!.lng.toStringAsFixed(5)})',
                      style: const TextStyle(color: Colors.grey),
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

          // FAB "Mi ubicación", justo arriba del +
          Positioned(
            right: 6,
            bottom: _seleccionado != null ? 225 : 110,
            child: FloatingActionButton.small(
              onPressed: _cargandoUbicacion ? null : _irAMiUbicacion,
              backgroundColor: Colors.green,
              child: _cargandoUbicacion
                  ? const SizedBox(
                      width: 18,
                      height: 16,
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
