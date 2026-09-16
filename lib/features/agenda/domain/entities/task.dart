class Task {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String date;
  final String time;
  final String status;
  final String priority;

  const Task({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.status,
    required this.priority,
  });
}