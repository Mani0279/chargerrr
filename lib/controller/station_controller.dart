import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/charging_station_model.dart';
import '../services/firebase_service.dart';

class StationController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();

  final RxList<ChargingStation> stations = <ChargingStation>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Location related
  final Rx<Position?> currentPosition = Rx<Position?>(null);
  final RxBool isLoadingLocation = false.obs;
  final RxSet<Marker> markers = <Marker>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStations();
    getCurrentLocation();
  }

  // Get current user location
  Future<void> getCurrentLocation() async {
    try {
      isLoadingLocation.value = true;

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar(
          'Location Disabled',
          'Please enable location services',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar(
            'Permission Denied',
            'Location permission is required',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
          'Permission Denied',
          'Please enable location permission in settings',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      currentPosition.value = position;
      print('📍 Current Location: ${position.latitude}, ${position.longitude}');

      Get.snackbar(
        'Location Found',
        'Current location updated',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('Error getting location: $e');
      Get.snackbar(
        'Error',
        'Failed to get current location',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingLocation.value = false;
    }
  }

  // Create markers for all stations
  void createStationMarkers() {
    markers.clear();

    for (var station in stations) {
      final marker = Marker(
        markerId: MarkerId(station.id),
        position: LatLng(station.latitude, station.longitude),
        infoWindow: InfoWindow(
          title: station.name,
          snippet: '${station.availablePoints}/${station.totalPoints} available',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          station.isAvailable ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed,
        ),
      );
      markers.add(marker);
    }

    print('🗺️ Created ${markers.length} markers');
  }

  // Fetch stations from Firebase
  Future<void> fetchStations() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final fetchedStations = await _firebaseService.getChargingStations();
      stations.value = fetchedStations;

      if (fetchedStations.isEmpty) {
        errorMessage.value = 'No charging stations found';
      } else {
        createStationMarkers();
      }
    } catch (e) {
      errorMessage.value = 'Failed to load stations: ${e.toString()}';
      Get.snackbar(
        'Error',
        'Failed to load charging stations',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
    debugPrintStations();
  }

  // Calculate distance from current location to station
  double? getDistanceToStation(ChargingStation station) {
    if (currentPosition.value == null) return null;

    return Geolocator.distanceBetween(
      currentPosition.value!.latitude,
      currentPosition.value!.longitude,
      station.latitude,
      station.longitude,
    ) / 1000; // Convert to kilometers
  }

  // Get station by ID
  ChargingStation? getStationById(String id) {
    try {
      return stations.firstWhere((station) => station.id == id);
    } catch (e) {
      return null;
    }
  }

  // Filter stations by availability
  List<ChargingStation> getAvailableStations() {
    return stations.where((station) => station.isAvailable).toList();
  }

  // Filter stations by amenity
  List<ChargingStation> getStationsByAmenity(String amenity) {
    return stations
        .where((station) => station.amenities.contains(amenity))
        .toList();
  }

  // Search stations by name or address
  List<ChargingStation> searchStations(String query) {
    final lowercaseQuery = query.toLowerCase();
    return stations.where((station) {
      return station.name.toLowerCase().contains(lowercaseQuery) ||
          station.address.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Sort stations by availability
  void sortByAvailability() {
    stations.sort((a, b) =>
        b.availabilityPercentage.compareTo(a.availabilityPercentage));
  }

  // Sort stations by distance from current location
  void sortByDistance() {
    if (currentPosition.value == null) {
      Get.snackbar(
        'Location Required',
        'Please enable location to sort by distance',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    stations.sort((a, b) {
      final distA = getDistanceToStation(a) ?? double.infinity;
      final distB = getDistanceToStation(b) ?? double.infinity;
      return distA.compareTo(distB);
    });
  }

  // Sort stations by name
  void sortByName() {
    stations.sort((a, b) => a.name.compareTo(b.name));
  }

  // Refresh stations
  Future<void> refreshStations() async {
    await fetchStations();
  }

  void debugPrintStations() {
    print('=== DEBUG STATIONS ===');
    print('Total stations: ${stations.length}');
    print('Is loading: ${isLoading.value}');
    print('Error message: ${errorMessage.value}');
    for (var station in stations) {
      print('Station: ${station.name} - ${station.id}');
    }
    print('==================');
  }
}