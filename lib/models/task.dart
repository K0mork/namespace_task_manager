enum TaskType {
  todo,
  reminder,
  calendar,
  memo,
}

class Task {
  final String id;
  final TaskType type;
  final String content;
  final String? date; // YYYYMMDD形式
  final String? time; // HHMM形式
  bool isCompleted;

  Task({
    required this.id,
    required this.type,
    required this.content,
    this.date,
    this.time,
    this.isCompleted = false,
  });

  // タスク文字列からTaskオブジェクトを生成
  static Task? fromString(String taskStr) {
    final parts = taskStr.split('::');
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    
    if (parts.isEmpty) return null;
    
    final namespace = parts[0].toLowerCase();
    
    if (namespace == 'todo' && parts.length >= 2) {
      return Task(
        id: id,
        type: TaskType.todo,
        content: parts[1],
      );
    } 
    else if (namespace == 'reminder' && parts.length >= 2) {
      if (parts.length == 2) {
        // reminder::content (メモとして扱う)
        return Task(
          id: id,
          type: TaskType.memo,
          content: parts[1],
        );
      } 
      else if (parts.length == 3) {
        if (RegExp(r'^\d{4}$').hasMatch(parts[1])) {
          // reminder::time::content (今日のリマインダー)
          final today = DateTime.now();
          final year = today.year.toString();
          final month = today.month.toString().padLeft(2, '0');
          final day = today.day.toString().padLeft(2, '0');
          final dateStr = '$year$month$day';
          
          return Task(
            id: id,
            type: TaskType.reminder,
            content: parts[2],
            date: dateStr,
            time: parts[1],
          );
        } else {
          // reminder::date::content
          return Task(
            id: id,
            type: TaskType.reminder,
            content: parts[2],
            date: parts[1],
          );
        }
      } 
      else if (parts.length == 4) {
        // reminder::date::time::content
        return Task(
          id: id,
          type: TaskType.reminder,
          content: parts[3],
          date: parts[1],
          time: parts[2],
        );
      }
    }
    else if (namespace == 'calendar' && parts.length >= 3) {
      // calendar::date::content
      return Task(
        id: id,
        type: TaskType.calendar,
        content: parts[2],
        date: parts[1],
      );
    }
    else if (namespace == 'memo' && parts.length >= 2) {
      // memo::content
      return Task(
        id: id,
        type: TaskType.memo,
        content: parts[1],
      );
    }
    
    return null;
  }

  // タスク文字列の検証
  static String? validateTaskString(String taskStr) {
    final parts = taskStr.split('::');
    
    if (parts.isEmpty) return "不正なタスク形式です";
    
    final namespace = parts[0].toLowerCase();
    
    if (namespace == 'reminder') {
      if (parts.length < 3) {
        return "reminder:: の後に日付を指定してください (例: reminder::20240101::メモ)";
      }
    } 
    else if (namespace == 'calendar') {
      if (parts.length < 3) {
        return "calendar:: の後に日付を指定してください (例: calendar::20240101::予定)";
      }
    }
    
    return null; // エラーなし
  }

  // フォーマットされた日付を取得 (YYYY/MM/DD)
  String? get formattedDate {
    if (date == null || date!.length != 8) return null;
    return '${date!.substring(0, 4)}/${date!.substring(4, 6)}/${date!.substring(6, 8)}';
  }

  // フォーマットされた時間を取得 (HH:MM)
  String? get formattedTime {
    if (time == null || time!.length != 4) return null;
    return '${time!.substring(0, 2)}:${time!.substring(2, 4)}';
  }
}
