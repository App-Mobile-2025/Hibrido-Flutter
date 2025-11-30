import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:reciclapp/ui/register/mapa/ecopuntos_ba.dart';

class EcopuntoMapScreen extends StatefulWidget {
  const EcopuntoMapScreen({super.key});

  @override
  State<EcopuntoMapScreen> createState() => _EcopuntoMapScreenState();
}

class _EcopuntoMapScreenState extends State<EcopuntoMapScreen> {
  GoogleMapController? _mapController;
  Ecopunto? _seleccionado;

  @override
  Widget build(BuildContext context) {
    final initial = EcopuntosBA.lista.first;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Elegir Ecopunto'),
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
          ),

          // Barra inferior con el ecopunto seleccionado
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
                        label: const Text('Usar este ecopunto'),
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
        ],
      ),
    );
  }
}
