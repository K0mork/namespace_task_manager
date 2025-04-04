import 'package:flutter/material.dart';

class TaskInput extends StatefulWidget {
  final Function(List<String>) onTaskSubmit;

  const TaskInput({super.key, required this.onTaskSubmit});

  @override
  TaskInputState createState() => TaskInputState();
}

class TaskInputState extends State<TaskInput> {
  final List<TextEditingController> _controllers = [TextEditingController()];

  void _addInputField() {
    setState(() {
      _controllers.add(TextEditingController());
    });
  }

  void _removeInputField(int index) {
    if (_controllers.length > 1) {
      setState(() {
        _controllers.removeAt(index);
      });
    } else {
      _controllers[0].clear();
    }
  }

  void _insertNamespace(String namespace) {
    if (_controllers.isNotEmpty) {
      // 現在フォーカスがあるコントローラーを探す
      final FocusNode? focusNode = FocusManager.instance.primaryFocus;
      int targetIndex = 0;
      
      if (focusNode != null) {
        // フォーカスされているコントローラーのインデックスを見つける
        for (int i = 0; i < _controllers.length; i++) {
          if (_controllers[i].text == focusNode.context?.widget.toString()) {
            targetIndex = i;
            break;
          }
        }
      }
      
      _controllers[targetIndex].text = namespace;
      _controllers[targetIndex].selection = TextSelection.fromPosition(
        TextPosition(offset: _controllers[targetIndex].text.length),
      );
    }
  }

  void _insertDate(String type) {
    final now = DateTime.now();
    final targetDate = type == 'tomorrow' ? 
      DateTime(now.year, now.month, now.day + 1) : 
      DateTime(now.year, now.month, now.day);
    
    final year = targetDate.year.toString();
    final month = targetDate.month.toString().padLeft(2, '0');
    final day = targetDate.day.toString().padLeft(2, '0');
    final dateStr = '$year$month$day';
    
    if (_controllers.isNotEmpty) {
      final FocusNode? focusNode = FocusManager.instance.primaryFocus;
      int targetIndex = 0;
      
      if (focusNode != null) {
        for (int i = 0; i < _controllers.length; i++) {
          if (_controllers[i].text == focusNode.context?.widget.toString()) {
            targetIndex = i;
            break;
          }
        }
      }
      
      final currentValue = _controllers[targetIndex].text;
      
      if (currentValue.contains('::')) {
        final parts = currentValue.split('::');
        if (parts.length >= 2 && (parts[0] == 'reminder' || parts[0] == 'calendar')) {
          parts.insert(1, dateStr);
          _controllers[targetIndex].text = parts.join('::');
        } else {
          _controllers[targetIndex].text = '$currentValue$dateStr';
        }
      } else {
        _controllers[targetIndex].text = '$currentValue$dateStr';
      }
    }
  }

  void _processTasks() {
    final taskStrings = _controllers
      .map((controller) => controller.text.trim())
      .where((text) => text.isNotEmpty)
      .toList();
    
    widget.onTaskSubmit(taskStrings);
    
    // 入力フィールドをクリア
    for (var controller in _controllers) {
      controller.clear();
    }
    
    // 複数あるフィールドを1つだけ残す
    if (_controllers.length > 1) {
      setState(() {
        final firstController = _controllers.first;
        _controllers.clear();
        _controllers.add(firstController);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'クイック入力',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildNamespaceButton(
                'todo::',
                Colors.green,
                Icons.list_alt,
              ),
              _buildNamespaceButton(
                'reminder::',
                Colors.amber,
                Icons.notifications,
              ),
              _buildNamespaceButton(
                'calendar::',
                Colors.purple,
                Icons.calendar_today,
              ),
              _buildNamespaceButton(
                'memo::',
                Colors.blue,
                Icons.note,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '日付ショートカット',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildDateButton('today', '本日'),
              _buildDateButton('tomorrow', '明日'),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '入力フォーマット例',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("todo::書類作成 - Simple ToDo"),
                Text("reminder::1210::お昼ご飯 - Today's reminder"),
                Text("reminder::20241225::クリスマス - Date reminder"),
                Text("reminder::20241225::1200::プレゼント交換 - Time reminder"),
                Text("calendar::20240501::買い物 - Calendar event"),
                Text("memo::プロジェクトのアイデア - Simple memo"),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'タスク入力',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _controllers.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controllers[index],
                          decoration: InputDecoration(
                            hintText: 'Enter task in namespace format',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onSubmitted: (_) => _processTasks(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => _removeInputField(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          TextButton.icon(
            icon: const Icon(Icons.add, size: 16),
            label: const Text('タスクを追加'),
            onPressed: _addInputField,
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('タスクを適用'),
              onPressed: _processTasks,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNamespaceButton(String namespace, Color color, IconData icon) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 16),
      label: Text(namespace),
      onPressed: () => _insertNamespace(namespace),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildDateButton(String type, String label) {
    return OutlinedButton.icon(
      icon: Icon(
        type == 'today' ? Icons.today : Icons.event_available, 
        size: 16
      ),
      label: Text(label),
      onPressed: () => _insertDate(type),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.grey[700],
        side: BorderSide(color: Colors.grey[300]!),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
