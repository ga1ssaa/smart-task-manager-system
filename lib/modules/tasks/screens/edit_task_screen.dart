import 'package:flutter/material.dart';
import '../models/task_model.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;
  final Function(Task) onUpdate;

  const EditTaskScreen({
    super.key,
    required this.task,
    required this.onUpdate,
  });

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late TextEditingController titleController;
  late TextEditingController descController;

  late String category;
  late String priority;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.task.title);
    descController = TextEditingController(text: widget.task.description);
    category = widget.task.category;
    priority = widget.task.priority;
  }

  void save() {
    final updated = Task(
      id: widget.task.id,
      title: titleController.text,
      description: descController.text,
      category: category,
      priority: priority,
      isCompleted: widget.task.isCompleted,
    );

    widget.onUpdate(updated);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Task")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: titleController),
            TextField(controller: descController),

            const SizedBox(height: 10),

            DropdownButton<String>(
              value: category,
              items: ['Study', 'Work', 'Personal', 'Health']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => category = v!),
            ),

            DropdownButton<String>(
              value: priority,
              items: ['High', 'Medium', 'Low']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => priority = v!),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: save,
              child: const Text("Save Changes"),
            )
          ],
        ),
      ),
    );
  }
}