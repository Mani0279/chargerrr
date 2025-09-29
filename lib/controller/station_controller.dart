import 'package:get/get.dart';
import '../models/charging_station_model.dart';
import '../services/firebase_service.dart';

class StationController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();

  final RxList<ChargingStation> stations = <ChargingStation>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStations();
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
