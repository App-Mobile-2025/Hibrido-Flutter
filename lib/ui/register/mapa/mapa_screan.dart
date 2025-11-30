import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  LatLng? _selectedPosition;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    setState(() {});
  }

  Future<LatLng> _getUserLocation() async {
    final pos = await Geolocator.getCurrentPosition();
    return LatLng(pos.latitude, pos.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getUserLocation(),
      builder: (_, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final LatLng userPos = snapshot.data as LatLng;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Elegir ubicación"),
          ),
          body: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: userPos,
              zoom: 15,
            ),
            onMapCreated: (controller) => _controller = controller,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: _selectedPosition != null
                ? {
                    Marker(
                      markerId: const MarkerId("selected"),
                      position: _selectedPosition!,
                    )
                  }
                : {},
            onTap: (LatLng pos) {
              setState(() {
                _selectedPosition = pos;
              });
            },
          ),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.check),
            onPressed: () {
              if (_selectedPosition == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Elegí un punto en el mapa"),
                  ),
                );
                return;
              }

              Navigator.pop(context, _selectedPosition);
            },
          ),
        );
      },
    );
  }
}
