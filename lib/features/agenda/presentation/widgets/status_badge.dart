import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final bool completed = status == 'Completada';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: completed
            ? const Color(0xFF183027)
            : const Color(0xFF2A2046),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: completed
              ? const Color(0xFF2D5A49)
              : const Color(0xFF493574),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            completed
                ? Icons.check_circle_rounded
                : Icons.access_time_rounded,
            color: completed
                ? const Color(0xFF65D6A0)
                : const Color(0xFFA78BFA),
            size: 13,
          ),
          const SizedBox(width: 5),
          Text(
            status,
            style: TextStyle(
              color: completed
                  ? const Color(0xFF65D6A0)
                  : const Color(0xFFA78BFA),
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}