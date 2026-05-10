import 'package:flutter/material.dart';

import '../data/dummy_tasks.dart';
import '../models/task_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> tasks = dummyTasks;

  void deleteTask(String id) {
    setState(() {
      tasks.removeWhere((task) => task.id == id);
    });
  }

  void toggleComplete(int index) {
    setState(() {
      tasks[index].isCompleted = !tasks[index].isCompleted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        centerTitle: true,
      ),
      body: ReorderableListView.builder(
        itemCount: tasks.length,
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) {
              newIndex--;
            }

            final item = tasks.removeAt(oldIndex);
            tasks.insert(newIndex, item);
          });
        },
        itemBuilder: (context, index) {
          final task = tasks[index];

          return Dismissible(
            key: Key(task.id),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            onDismissed: (_) {
              deleteTask(task.id);
            },
            child: Card(
              key: ValueKey(task.id),
              margin: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              child: ListTile(
                leading: Checkbox(
                  value: task.isCompleted,
                  onChanged: (_) {
                    toggleComplete(index);
                  },
                ),
                title: Text(task.title),
                subtitle: Text(
                  '${task.category} • ${task.priority}',
                ),
                trailing: const Icon(Icons.drag_handle),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}