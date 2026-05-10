class Task {
  String id;
  String title;
  String description;
  String category;
  String priority;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    this.isCompleted = false,
  });
}