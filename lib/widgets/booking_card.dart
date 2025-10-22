import 'package:flutter/material.dart';

class Booking {
  final String code;
  final String service;
  final String vehicle;
  final String status;

  Booking({
    required this.code,
    required this.service,
    required this.vehicle,
    required this.status,
  });
}

class BookingCard extends StatelessWidget {
  final Booking booking;
  final double progress; // optional: cho progress indicator linh hoạt

  const BookingCard({super.key, required this.booking, this.progress = 0.6});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final backgroundColor = theme.cardColor;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: primaryColor.withOpacity(0.3),
      color: backgroundColor,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pending_actions, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Booking In Progress',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              booking.code,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${booking.vehicle} - ${booking.service}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 16,
                    backgroundColor: theme.dividerColor,
                    color: primaryColor,
                  ),
                  Positioned.fill(
                    child: Center(
                      child: Text(
                        booking.status,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
