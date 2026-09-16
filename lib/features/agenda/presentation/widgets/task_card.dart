import 'package:flutter/material.dart';

class TaskCard extends StatelessWidget {
  final String title;
  final String description;
  final String date;
  final String time;
  final String status;
  final String priority;

  const TaskCard({
    super.key,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.status,
    required this.priority,
  });

  @override
  Widget build(BuildContext context) {
    final bool completed = status == 'Completada';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF151624),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: completed
              ? const Color(0xFF263B35)
              : const Color(0xFF292B40),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 15,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTaskIcon(completed),

                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: completed
                              ? const Color(0xFF85889D)
                              : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          decoration: completed
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF85889D),
                          fontSize: 12.5,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                _buildStatus(status),
              ],
            ),

            const Spacer(),

            const Divider(
              color: Color(0xFF292B40),
              height: 25,
            ),

            Row(
              children: [
                _buildInfo(
                  icon: Icons.calendar_today_rounded,
                  text: date,
                ),

                const SizedBox(width: 15),

                _buildInfo(
                  icon: Icons.access_time_rounded,
                  text: time,
                ),

                const Spacer(),

                _buildPriority(priority),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskIcon(bool completed) {
    return Container(
      width: 43,
      height: 43,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: completed
              ? const [
                  Color(0xFF263B35),
                  Color(0xFF1B2926),
                ]
              : const [
                  Color(0xFF30205A),
                  Color(0xFF1E1638),
                ],
        ),
      ),
      child: Icon(
        completed
            ? Icons.check_rounded
            : Icons.task_alt_rounded,
        color: completed
            ? const Color(0xFF65D6A0)
            : const Color(0xFFA78BFA),
        size: 22,
      ),
    );
  }

  Widget _buildStatus(String status) {
    final bool completed = status == 'Completada';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: completed
            ? const Color(0xFF183027)
            : const Color(0xFF2A2046),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: completed
              ? const Color(0xFF65D6A0)
              : const Color(0xFFA78BFA),
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildInfo({
    required IconData icon,
    required String text,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: const Color(0xFF777A91),
          size: 15,
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFF9698AA),
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPriority(String priority) {
    Color color;

    switch (priority) {
      case 'Alta':
        color = const Color(0xFFF87171);
        break;

      case 'Media':
        color = const Color(0xFFFBBF24);
        break;

      default:
        color = const Color(0xFF65D6A0);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 6),

        Text(
          priority,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}