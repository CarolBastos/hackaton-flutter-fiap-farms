import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPickerScreen extends StatefulWidget {
  final double initialLat;
  final double initialLong;

  const LocationPickerScreen({
    super.key,
    required this.initialLat,
    required this.initialLong,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late GoogleMapController mapController;
  LatLng _selectedLocation = LatLng(0, 0);

  @override
  void initState() {
    super.initState();
    _selectedLocation = LatLng(widget.initialLat, widget.initialLong);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecionar Localização'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context, {
                'latitude': _selectedLocation.latitude,
                'longitude': _selectedLocation.longitude,
              });
            },
          ),
        ],
      ),
      body: GoogleMap(
        onMapCreated: (controller) {
          mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: _selectedLocation,
          zoom: 14,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('selected_location'),
            position: _selectedLocation,
            draggable: true,
          ),
        },
        onTap: (LatLng location) {
          setState(() {
            _selectedLocation = location;
          });
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}