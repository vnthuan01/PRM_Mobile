import 'package:flutter/material.dart';

class Vehicle {
  final String name;
  final String status;

  Vehicle({required this.name, required this.status});
}

class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final double width;
  final double height;

  const VehicleCard({
    super.key,
    required this.vehicle,
    this.width = 300,
    this.height = 220,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          // Gradient overlay
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.cardColor.withOpacity(0.6), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          // Text info
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: vehicle.status == 'Đang bảo dưỡng'
                        ? Colors.orangeAccent
                        : Colors.greenAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    vehicle.status,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
