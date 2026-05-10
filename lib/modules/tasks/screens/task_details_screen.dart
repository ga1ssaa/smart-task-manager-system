import 'package:flutter/material.dart';
import '../models/task_model.dart';

class TaskDetailsScreen extends StatelessWidget {
  final Task task;

  const TaskDetailsScreen({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    Color priorityColor;

    switch (task.priority) {
      case 'High':
        priorityColor = Colors.red;
        break;
      case 'Medium':
        priorityColor = Colors.orange;
        break;
      default:
        priorityColor = Colors.green;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Task Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              task.description,
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Chip(
                  label: Text(task.category),
                ),
                const SizedBox(width: 10),
                Chip(
                  label: Text(
                    task.priority,
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: priorityColor,
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Icon(
                  task.isCompleted
                      ? Icons.check_circle
                      : Icons.circle_outlined,
                  color: task.isCompleted ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  task.isCompleted ? "Completed" : "Not Completed",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}