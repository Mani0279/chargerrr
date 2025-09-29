class ChargingStation {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final int availablePoints;
  final int totalPoints;
  final List<String> amenities;

  ChargingStation({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.availablePoints,
    required this.totalPoints,
    required this.amenities,
  });

  // From JSON
  factory ChargingStation.fromJson(Map<dynamic, dynamic> json) {
    return ChargingStation(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      availablePoints: json['available_points'] ?? 0,
      totalPoints: json['total_points'] ?? 0,
      amenities: List<String>.from(json['amenities'] ?? []),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'available_points': availablePoints,
      'total_points': totalPoints,
      'amenities': amenities,
    };
  }

  // Calculate availability percentage
  double get availabilityPercentage {
    if (totalPoints == 0) return 0;
    return (availablePoints / totalPoints) * 100;
  }

  // Check if station is available
  bool get isAvailable => availablePoints > 0;

  // Get amenity icon
  static String getAmenityIcon(String amenity) {
    switch (amenity.toLowerCase()) {
      case 'wifi':
        return '📶';
      case 'restroom':
        return '🚻';
      case 'cafe':
        return '☕';
      case 'food_court':
        return '🍽️';
      case 'parking':
        return '🅿️';
      case 'atm':
        return '🏧';
      default:
        return '✓';
    }
  }

  // Get amenity label
  static String getAmenityLabel(String amenity) {
    return amenity.replaceAll('_', ' ').toUpperCase();
  }
}