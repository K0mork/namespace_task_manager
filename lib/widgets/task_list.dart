import 'package:flutter/material.dart';
import '../models/task.dart';
import '../utils/ical_export.dart';

class TaskList extends StatelessWidget {
  final List<Task> tasks;
  final Function(Task) onRemove;
  final Function(Task) onToggle;
  final TaskType taskType;

  const TaskList({
    super.key,
    required this.tasks,
    required this.onRemove,
    required this.onToggle,
    required this.taskType,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
          'タスクがありません',
          style: TextStyle(
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        
        switch (taskType) {
          case TaskType.todo:
            return _buildTodoItem(context, task);
          case TaskType.reminder:
            return _buildReminderItem(context, task);
          case TaskType.calendar:
            return _buildCalendarItem(context, task);
          case TaskType.memo:
            return _buildMemoItem(context, task);
        }
      },
    );
  }

  Widget _buildTodoItem(BuildContext context, Task task) {
    return Card(
      color: Colors.green[50],
      margin: const EdgeInsets.only(bottom: 8, right: 8),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          activeColor: Colors.green,
          onChanged: (_) => onToggle(task),
        ),
        title: Text(
          task.content,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, size: 20),
          color: Colors.grey[600],
          onPressed: () => onRemove(task),
        ),
      ),
    );
  }

  Widget _buildReminderItem(BuildContext context, Task task) {
    String dateTimeDisplay = '';
    if (task.formattedDate != null) {
      dateTimeDisplay = task.formattedDate!;
      if (task.formattedTime != null) {
        dateTimeDisplay += ' ${task.formattedTime!}';
      }
    }

    return Card(
      color: Colors.amber[50],
      margin: const EdgeInsets.only(bottom: 8, right: 8),
      child: ListTile(
        leading: const Icon(Icons.notifications, color: Colors.amber),
        title: Text(task.content),
        subtitle: dateTimeDisplay.isNotEmpty ? Text(dateTimeDisplay) : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (task.date != null)
              IconButton(
                icon: const Icon(Icons.calendar_today_outlined, size: 20),
                color: Colors.grey[600],
                onPressed: () {
                  exportToCalendar(context, task);
                },
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              color: Colors.grey[600],
              onPressed: () => onRemove(task),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarItem(BuildContext context, Task task) {
    return Card(
      color: Colors.purple[50],
      margin: const EdgeInsets.only(bottom: 8, right: 8),
      child: ListTile(
        leading: const Icon(Icons.calendar_today, color: Colors.purple),
        title: Text(task.content),
        subtitle: task.formattedDate != null ? Text(task.formattedDate!) : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.calendar_today_outlined, size: 20),
              color: Colors.grey[600],
              onPressed: () {
                exportToCalendar(context, task);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              color: Colors.grey[600],
              onPressed: () => onRemove(task),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemoItem(BuildContext context, Task task) {
    return Card(
      color: Colors.blue[50],
      margin: const EdgeInsets.only(bottom: 8, right: 8),
      child: ListTile(
        leading: const Icon(Icons.note, color: Colors.blue),
        title: Text(task.content),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, size: 20),
          color: Colors.grey[600],
          onPressed: () => onRemove(task),
        ),
      ),
    );
  }
}
