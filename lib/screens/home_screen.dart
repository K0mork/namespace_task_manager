import 'package:flutter/material.dart';
import '../models/task.dart';
import '../widgets/task_input.dart';
import '../widgets/task_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  // タスクのリスト
  final List<Task> _todos = [];
  final List<Task> _reminders = [];
  final List<Task> _calendar = [];
  final List<Task> _memos = [];

  // タスクを追加
  void _addTask(Task task) {
    setState(() {
      switch (task.type) {
        case TaskType.todo:
          _todos.add(task);
          break;
        case TaskType.reminder:
          _reminders.add(task);
          break;
        case TaskType.calendar:
          _calendar.add(task);
          break;
        case TaskType.memo:
          _memos.add(task);
          break;
      }
    });
  }

  // タスクを削除
  void _removeTask(Task task) {
    setState(() {
      switch (task.type) {
        case TaskType.todo:
          _todos.removeWhere((t) => t.id == task.id);
          break;
        case TaskType.reminder:
          _reminders.removeWhere((t) => t.id == task.id);
          break;
        case TaskType.calendar:
          _calendar.removeWhere((t) => t.id == task.id);
          break;
        case TaskType.memo:
          _memos.removeWhere((t) => t.id == task.id);
          break;
      }
    });
  }

  // タスク完了状態の切り替え
  void _toggleTaskCompletion(Task task) {
    setState(() {
      task.isCompleted = !task.isCompleted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.code, color: Colors.blue),
            SizedBox(width: 8),
            Text('Namespace Tasks'),
          ],
        ),
        elevation: 1,
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.landscape || MediaQuery.of(context).size.width > 600) {
            // タブレットやデスクトップ向けのレイアウト（横向き）
            return Row(
              children: [
                // 左側のサイドバー
                Expanded(
                  flex: 1,
                  child: _buildSidebar(),
                ),
                // 右側の入力エリア
                Expanded(
                  flex: 2,
                  child: TaskInput(onTaskSubmit: _processTasks),
                ),
              ],
            );
          } else {
            // スマートフォン向けのレイアウト（縦向き）
            return Column(
              children: [
                // リストは上部に
                Expanded(
                  child: _buildSidebar(),
                ),
                // 入力エリアは下部に
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: TaskInput(onTaskSubmit: _processTasks),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  // サイドバー（タスクリスト表示部分）を構築
  Widget _buildSidebar() {
    return Container(
      color: Colors.grey[50],
      child: ListView(
        children: [
          _buildTaskSection(
            icon: Icons.list_alt, 
            title: 'ToDo', 
            color: Colors.green, 
            tasks: _todos,
            taskType: TaskType.todo,
          ),
          _buildTaskSection(
            icon: Icons.notifications, 
            title: 'Reminders', 
            color: Colors.amber, 
            tasks: _reminders,
            taskType: TaskType.reminder,
          ),
          _buildTaskSection(
            icon: Icons.calendar_today, 
            title: 'Calendar', 
            color: Colors.purple, 
            tasks: _calendar,
            taskType: TaskType.calendar,
          ),
          _buildTaskSection(
            icon: Icons.note, 
            title: 'Memos', 
            color: Colors.blue, 
            tasks: _memos,
            taskType: TaskType.memo,
          ),
        ],
      ),
    );
  }

  // タスクセクションを構築
  Widget _buildTaskSection({
    required IconData icon, 
    required String title, 
    required Color color,
    required List<Task> tasks,
    required TaskType taskType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: color.withOpacity(0.3),
                  width: 2,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: TaskList(
                tasks: tasks, 
                onRemove: _removeTask,
                onToggle: _toggleTaskCompletion,
                taskType: taskType,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Divider(),
      ],
    );
  }

  // タスクを処理
  void _processTasks(List<String> taskStrings) {
    for (final taskStr in taskStrings) {
      if (taskStr.trim().isNotEmpty) {
        final task = Task.fromString(taskStr);
        if (task != null) {
          _addTask(task);
        }
      }
    }
  }
}
