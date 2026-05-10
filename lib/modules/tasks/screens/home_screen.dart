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

final searchController = TextEditingController();
List<Task> filteredTasks = [];
TextField(
  controller: searchController,
  onChanged: searchTask,
  decoration: const InputDecoration(
    hintText: "Search tasks...",
    prefixIcon: Icon(Icons.search),
  ),
),

@override
void initState() {
  super.initState();
  filteredTasks = tasks;
}
void searchTask(String query) {
  setState(() {
    filteredTasks = tasks
        .where((task) =>
            task.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  });
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> tasks = dummyTasks;

  void deleteTask(String id) {
    setState(() {
      tasks.removeWhere((task) => task.id == id);
    });
  }

  void addTask(Task task) {
    setState(() {
      tasks.add(task);
    });
  }
  void updateTask(Task updatedTask) {
  setState(() {
    final index = tasks.indexWhere((t) => t.id == updatedTask.id);
    tasks[index] = updatedTask;
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
        itemCount: filteredTasks.length,
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
  onLongPress: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EditTaskScreen(
        task: task,
        onUpdate: updateTask,
      ),
    ),
  );
},
  title: Text(task.title),
  subtitle: Text('${task.category} • ${task.priority}'),
  style: TextStyle(
    color: task.priority == 'High'
        ? Colors.red
        : task.priority == 'Medium'
            ? Colors.orange
            : Colors.green,
  ),
),
  trailing: const Icon(Icons.drag_handle),

  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailsScreen(task: task),
      ),
    );
  },
)
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
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateTaskScreen(
          onAddTask: addTask,
        ),
      ),
    );
  },
  child: const Icon(Icons.add),
),
        child: const Icon(Icons.add),
      ),
    );
  }
}