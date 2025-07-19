import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fiap_farms/domain/entities/farm.dart';

class FarmDetailsScreen extends StatefulWidget {
  final Farm farm;

  const FarmDetailsScreen({super.key, required this.farm});

  @override
  State<FarmDetailsScreen> createState() => _FarmDetailsScreenState();
}

class _FarmDetailsScreenState extends State<FarmDetailsScreen> {
  late GoogleMapController mapController;
  bool _mapCreated = false;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final mapHeight = screenHeight * 0.6; // 70% da altura da tela

    return Scaffold(
      appBar: AppBar(title: Text(widget.farm.name)),
      body: Column(
        children: [
          SizedBox(
            height: mapHeight,
            child: _mapCreated
                ? GoogleMap(
                    onMapCreated: (controller) {
                      mapController = controller;
                    },
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        widget.farm.location.latitude,
                        widget.farm.location.longitude,
                      ),
                      zoom: 15,
                    ),
                    markers: {
                      Marker(
                        markerId: MarkerId(widget.farm.id),
                        position: LatLng(
                          widget.farm.location.latitude,
                          widget.farm.location.longitude,
                        ),
                        infoWindow: InfoWindow(title: widget.farm.name),
                      ),
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.farm.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tipo de Produto: ${widget.farm.productType}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    'Produção Anual: ${widget.farm.annualProduction.toStringAsFixed(1)} ton',
                  ),
                  if (widget.farm.address != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text('Endereço: ${widget.farm.address}'),
                    ),
                  // Adicione mais informações da fazenda aqui se necessário
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Delay para garantir que o mapa seja criado após o build
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() => _mapCreated = true);
      }
    });
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }
}
