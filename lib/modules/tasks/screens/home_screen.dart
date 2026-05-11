import 'package:flutter/material.dart';

import '../data/dummy_tasks.dart';
import '../models/task_model.dart';
import 'create_task_screen.dart';
import 'task_details_screen.dart';
import 'edit_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final searchController = TextEditingController();

  List<Task> tasks = dummyTasks;
  List<Task> filteredTasks = [];

  @override
  void initState() {
    super.initState();
    filteredTasks = tasks;
  }

  void searchTask(String query) {
    setState(() {
      filteredTasks = tasks
          .where(
            (task) => task.title
                .toLowerCase()
                .contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  void deleteTask(String id) {
    setState(() {
      tasks.removeWhere((task) => task.id == id);
      searchTask(searchController.text);
    });
  }

  void addTask(Task task) {
    setState(() {
      tasks.add(task);
      searchTask(searchController.text);
    });
  }

  void updateTask(Task updatedTask) {
    setState(() {
      final index =
          tasks.indexWhere((t) => t.id == updatedTask.id);

      tasks[index] = updatedTask;
      searchTask(searchController.text);
    });
  }

  void toggleComplete(int index) {
    setState(() {
      filteredTasks[index].isCompleted =
          !filteredTasks[index].isCompleted;
    });
  }

  Color priorityColor(String priority) {
    if (priority == "High") return Colors.red;
    if (priority == "Medium") return Colors.orange;

    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Task Manager"),
        centerTitle: true,
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              onChanged: searchTask,
              decoration: const InputDecoration(
                hintText: "Search tasks...",
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),

          Expanded(
            child: ReorderableListView.builder(
              itemCount: filteredTasks.length,

              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex--;
                  }

                  final item =
                      filteredTasks.removeAt(oldIndex);

                  filteredTasks.insert(
                    newIndex,
                    item,
                  );
                });
              },

              itemBuilder: (context, index) {
                final task = filteredTasks[index];

                return Dismissible(
                  key: Key(task.id),

                  background: Container(
                    color: Colors.red,
                    alignment:
                        Alignment.centerRight,

                    padding:
                        const EdgeInsets.only(
                      right: 20,
                    ),

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

                    margin:
                        const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),

                    child: ListTile(
                      leading: Checkbox(
                        value: task.isCompleted,
                        onChanged: (_) {
                          toggleComplete(
                            index,
                          );
                        },
                      ),

                      title: Text(
                        task.title,
                        style: TextStyle(
                          color: priorityColor(
                            task.priority,
                          ),
                        ),
                      ),

                      subtitle: Text(
                        "${task.category} • ${task.priority}",
                      ),

                      trailing: const Icon(
                        Icons.drag_handle,
                      ),

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                TaskDetailsScreen(
                              task: task,
                            ),
                          ),
                        );
                      },

                      onLongPress: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                EditTaskScreen(
                              task: task,
                              onUpdate:
                                  updateTask,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton:
          FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  CreateTaskScreen(
                onAddTask: addTask,
              ),
            ),
          );
        },

        child: const Icon(Icons.add),
      ),
    );
  }
}