import 'package:flutter/material.dart';

class AmenityChip extends StatelessWidget {
  final String amenity;
  final bool compact;

  const AmenityChip({
    super.key,
    required this.amenity,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: _getAmenityColor(amenity).withOpacity(0.1),
        borderRadius: BorderRadius.circular(compact ? 8 : 10),
        border: Border.all(
          color: _getAmenityColor(amenity).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getAmenityIcon(amenity),
            size: compact ? 14 : 16,
            color: _getAmenityColor(amenity),
          ),
          SizedBox(width: compact ? 4 : 6),
          Text(
            _formatAmenity(amenity),
            style: TextStyle(
              fontSize: compact ? 11 : 13,
              fontWeight: FontWeight.w600,
              color: _getAmenityColor(amenity),
            ),
          ),
        ],
      ),
    );
  }

  // Get icon based on amenity type
  IconData _getAmenityIcon(String amenity) {
    switch (amenity.toLowerCase()) {
      case 'wifi':
        return Icons.wifi;
      case 'restroom':
        return Icons.wc;
      case 'cafe':
        return Icons.local_cafe;
      case 'food_court':
        return Icons.restaurant;
      case 'parking':
        return Icons.local_parking;
      case 'atm':
        return Icons.atm;
      case 'shop':
        return Icons.shopping_bag;
      case 'lounge':
        return Icons.chair;
      default:
        return Icons.check_circle;
    }
  }

  // Get color based on amenity type
  Color _getAmenityColor(String amenity) {
    switch (amenity.toLowerCase()) {
      case 'wifi':
        return Colors.blue;
      case 'restroom':
        return Colors.teal;
      case 'cafe':
        return Colors.brown;
      case 'food_court':
        return Colors.orange;
      case 'parking':
        return Colors.indigo;
      case 'atm':
        return Colors.green;
      case 'shop':
        return Colors.purple;
      case 'lounge':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  // Format amenity string (capitalize and replace underscores)
  String _formatAmenity(String amenity) {
    return amenity
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}