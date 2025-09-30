import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../controller/station_controller.dart';
import '../../models/charging_station_model.dart';
import '../../services/firebase_service.dart';
import 'dart:async';

class AddStationScreen extends StatefulWidget {
  final double? latitude;
  final double? longitude;

  const AddStationScreen({
    Key? key,
    this.latitude,
    this.longitude,
  }) : super(key: key);

  @override
  State<AddStationScreen> createState() => _AddStationScreenState();
}

class _AddStationScreenState extends State<AddStationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _availablePointsController = TextEditingController();
  final _totalPointsController = TextEditingController();

  late double _selectedLat;
  late double _selectedLng;
  final List<String> _selectedAmenities = [];
  bool _isSubmitting = false;

  final List<String> _availableAmenities = [
    'wifi',
    'restroom',
    'cafe',
    'food_court',
    'parking',
    'atm',
  ];

  final Completer<GoogleMapController> _controller = Completer();
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _selectedLat = widget.latitude ?? 28.6139; // Default Delhi
    _selectedLng = widget.longitude ?? 77.2090;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _availablePointsController.dispose();
    _totalPointsController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Charging Station',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Map Section
            Container(
              height: 300,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(_selectedLat, _selectedLng),
                  zoom: 15,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('new_station'),
                    position: LatLng(_selectedLat, _selectedLng),
                    draggable: true,
                    onDragEnd: (LatLng position) {
                      setState(() {
                        _selectedLat = position.latitude;
                        _selectedLng = position.longitude;
                      });
                    },
                  ),
                },
                onMapCreated: (GoogleMapController controller) {
                  if (!_controller.isCompleted) {
                    _controller.complete(controller);
                    _mapController = controller;
                  }
                },
                onTap: (LatLng position) {
                  setState(() {
                    _selectedLat = position.latitude;
                    _selectedLng = position.longitude;
                  });
                },
              ),
            ),

            // Form Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Instructions
                    Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue.shade700),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Tap or drag the marker on the map to select location',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Location Display
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Selected Location',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Latitude: ${_selectedLat.toStringAsFixed(6)}',
                              style: const TextStyle(fontSize: 13),
                            ),
                            Text(
                              'Longitude: ${_selectedLng.toStringAsFixed(6)}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Station Name
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Station Name *',
                        hintText: 'e.g., Tata Power EZ Charge',
                        prefixIcon: const Icon(Icons.ev_station),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter station name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Address
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Address *',
                        hintText: 'Full address with city and pincode',
                        prefixIcon: const Icon(Icons.location_on),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Charging Points
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _availablePointsController,
                            decoration: InputDecoration(
                              labelText: 'Available Points *',
                              prefixIcon: const Icon(Icons.check_circle),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Invalid number';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _totalPointsController,
                            decoration: InputDecoration(
                              labelText: 'Total Points *',
                              prefixIcon: const Icon(Icons.numbers),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Invalid number';
                              }
                              final total = int.parse(value);
                              final available = int.tryParse(_availablePointsController.text) ?? 0;
                              if (available > total) {
                                return 'Cannot exceed total';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Amenities
                    const Text(
                      'Amenities',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableAmenities.map((amenity) {
                        final isSelected = _selectedAmenities.contains(amenity);
                        return FilterChip(
                          label: Text(_formatAmenity(amenity)),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedAmenities.add(amenity);
                              } else {
                                _selectedAmenities.remove(amenity);
                              }
                            });
                          },
                          selectedColor: Colors.green.shade100,
                          checkmarkColor: Colors.green.shade700,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitStation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : const Text(
                          'Add Station',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitStation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Generate unique ID
      final stationId = 'station-${DateTime.now().millisecondsSinceEpoch}';

      // Create station object
      final newStation = ChargingStation(
        id: stationId,
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        latitude: _selectedLat,
        longitude: _selectedLng,
        availablePoints: int.parse(_availablePointsController.text),
        totalPoints: int.parse(_totalPointsController.text),
        amenities: _selectedAmenities,
      );

      // Save to Firebase
      final firebaseService = FirebaseService();
      await firebaseService.addChargingStation(newStation);

      // Refresh stations in controller
      final stationController = Get.find<StationController>();
      await stationController.fetchStations();

      // Show success message
      Get.snackbar(
        'Success',
        'Charging station added successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Go back
      Get.back();
      Get.back(); // Go back twice to return to home
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add station: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  String _formatAmenity(String amenity) {
    return amenity
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}