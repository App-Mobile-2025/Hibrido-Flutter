import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapCardWidget extends StatelessWidget {
  final LatLng coords;
  final String ecopunto;

  const MapCardWidget({super.key, required this.coords, required this.ecopunto});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Ubicación:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(ecopunto),
              ],
            ),
          ),
          SizedBox(
            height: 250,
            width: double.infinity, 
            /*child: GoogleMap(
              initialCameraPosition: CameraPosition(target: coords, zoom: 15),
              markers: {
                Marker(
                  markerId: const MarkerId("ecopunto"),
                  position: coords,
                  infoWindow: InfoWindow(title: ecopunto),
                ),
              },
              zoomControlsEnabled: false,
              scrollGesturesEnabled: false,
              tiltGesturesEnabled: false,
              rotateGesturesEnabled: false,
            ),*/
          ),
        ],
      ),
    );
  }
}
