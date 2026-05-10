import 'package:flutter/material.dart';
import '../models/task_model.dart';

class CreateTaskScreen extends StatefulWidget {
  final Function(Task) onAddTask;

  const CreateTaskScreen({
    super.key,
    required this.onAddTask,
  });

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final titleController = TextEditingController();
  final descController = TextEditingController();

  String selectedCategory = 'Study';
  String selectedPriority = 'Medium';

  void saveTask() {
    if (titleController.text.isEmpty) return;

    final newTask = Task(
      id: DateTime.now().toString(),
      title: titleController.text,
      description: descController.text,
      category: selectedCategory,
      priority: selectedPriority,
    );

    widget.onAddTask(newTask);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Task"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Title",
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: "Description",
              ),
            ),
            const SizedBox(height: 20),

            // CATEGORY
            DropdownButton<String>(
              value: selectedCategory,
              items: ['Study', 'Work', 'Personal', 'Health']
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
            ),

            const SizedBox(height: 10),

            // PRIORITY
            DropdownButton<String>(
              value: selectedPriority,
              items: ['High', 'Medium', 'Low']
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedPriority = value!;
                });
              },
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: saveTask,
              child: const Text("Save Task"),
            )
          ],
        ),
      ),
    );
  }
}