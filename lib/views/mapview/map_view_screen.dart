import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import '../../controller/station_controller.dart';
import '../station_detail_screen/station_detail_screen.dart';
import '../add_station/add_station_screen.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({Key? key}) : super(key: key);

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  GoogleMapController? _mapController;
  final stationController = Get.find<StationController>();

  // Default position (India)
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(20.5937, 78.9629),
    zoom: 5,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _moveToCurrentLocation();
    });
  }

  Future<void> _moveToCurrentLocation() async {
    if (stationController.currentPosition.value != null) {
      final position = stationController.currentPosition.value!;
      final controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 12,
          ),
        ),
      );
    }
  }

  Set<Marker> _buildMarkers() {
    Set<Marker> markers = {};

    // Add station markers with onTap callback
    for (var station in stationController.stations) {
      markers.add(
        Marker(
          markerId: MarkerId(station.id),
          position: LatLng(station.latitude, station.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            station.isAvailable ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed,
          ),
          infoWindow: InfoWindow(
            title: station.name,
            snippet: '${station.availablePoints}/${station.totalPoints} available',
            onTap: () {
              // Navigate to detail screen when info window is tapped
              Get.to(() => StationDetailScreen(station: station));
            },
          ),
          onTap: () {
            // This shows the info window when marker is tapped
          },
        ),
      );
    }

    // Add current location marker
    if (stationController.currentPosition.value != null) {
      final pos = stationController.currentPosition.value!;
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(pos.latitude, pos.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(
            title: 'Your Location',
            snippet: 'You are here',
          ),
        ),
      );
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Stations Map',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          // Current Location Button
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () async {
              await stationController.getCurrentLocation();
              _moveToCurrentLocation();
            },
            tooltip: 'My Location',
          ),
        ],
      ),
      body: Obx(() {
        if (stationController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Stack(
          children: [
            GoogleMap(
              initialCameraPosition: _initialPosition,
              markers: _buildMarkers(),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                if (!_controller.isCompleted) {
                  _controller.complete(controller);
                  _mapController = controller;
                }
              },
              onLongPress: (LatLng position) {
                _showAddStationDialog(position);
              },
            ),

            // Station Count Card
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.ev_station, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            '${stationController.stations.length} Stations',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Get.to(() => const AddStationScreen());
                        },
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text('Add'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Legend
            Positioned(
              bottom: 16,
              left: 16,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Legend',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on, color: Colors.blue.shade600, size: 20),
                          const SizedBox(width: 4),
                          const Text('Your Location', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on, color: Colors.green.shade600, size: 20),
                          const SizedBox(width: 4),
                          const Text('Available', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on, color: Colors.red.shade600, size: 20),
                          const SizedBox(width: 4),
                          const Text('Full', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Instructions Card
            Positioned(
              bottom: 16,
              right: 16,
              child: Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.info_outline, color: Colors.green.shade700, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Tip',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap marker to see info\nLong-press map to add',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.green.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _showAddStationDialog(LatLng position) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Station Here?'),
        content: Text(
          'Do you want to add a new charging station at:\n'
              'Lat: ${position.latitude.toStringAsFixed(6)}\n'
              'Lng: ${position.longitude.toStringAsFixed(6)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Get.to(() => AddStationScreen(
                latitude: position.latitude,
                longitude: position.longitude,
              ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add Station'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}