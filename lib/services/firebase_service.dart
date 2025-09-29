import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/charging_station_model.dart';

class FirebaseService {
  // CRITICAL: Use the Asia Southeast regional database URL
  final DatabaseReference _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://chargerrr-9930b-default-rtdb.asia-southeast1.firebasedatabase.app',
  ).ref();

  // Get all charging stations
  Future<List<ChargingStation>> getChargingStations() async {
    try {
      final snapshot = await _database.child('charging_stations').get();

      if (!snapshot.exists) {
        return [];
      }

      final data = snapshot.value;
      final List<ChargingStation> stations = [];

      if (data is Map) {
        data.forEach((key, value) {
          if (value is Map) {
            try {
              final station = ChargingStation.fromJson(
                Map<String, dynamic>.from(value),
              );
              stations.add(station);
            } catch (e) {
              print('Error parsing station $key: $e');
            }
          }
        });
      }

      return stations;
    } catch (e) {
      print('Error fetching charging stations: $e');
      rethrow;
    }
  }

  // Get a specific charging station by ID
  Future<ChargingStation?> getChargingStationById(String stationId) async {
    try {
      final snapshot = await _database
          .child('charging_stations')
          .child(stationId)
          .get();

      if (!snapshot.exists) {
        return null;
      }

      final data = snapshot.value;
      if (data is Map) {
        return ChargingStation.fromJson(
          Map<String, dynamic>.from(data as Map),
        );
      }

      return null;
    } catch (e) {
      print('Error fetching station by ID: $e');
      rethrow;
    }
  }

  // Add a new charging station (for admin purposes)
  Future<void> addChargingStation(ChargingStation station) async {
    try {
      await _database
          .child('charging_stations')
          .child(station.id)
          .set(station.toJson());
    } catch (e) {
      print('Error adding charging station: $e');
      rethrow;
    }
  }

  // Update charging station availability
  Future<void> updateStationAvailability(
      String stationId,
      int availablePoints,
      ) async {
    try {
      await _database
          .child('charging_stations')
          .child(stationId)
          .update({'available_points': availablePoints});
    } catch (e) {
      print('Error updating station availability: $e');
      rethrow;
    }
  }

  // Delete a charging station
  Future<void> deleteChargingStation(String stationId) async {
    try {
      await _database
          .child('charging_stations')
          .child(stationId)
          .remove();
    } catch (e) {
      print('Error deleting station: $e');
      rethrow;
    }
  }
}