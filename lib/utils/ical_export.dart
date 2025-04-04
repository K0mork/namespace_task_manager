import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/task.dart';

void exportToCalendar(BuildContext context, Task task) async {
  if (task.date == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('日付が指定されていないため、カレンダーにエクスポートできません')),
    );
    return;
  }

  try {
    // 日時のパース
    final year = int.parse(task.date!.substring(0, 4));
    final month = int.parse(task.date!.substring(4, 6));
    final day = int.parse(task.date!.substring(6, 8));
    
    int hour = 0;
    int minute = 0;
    
    if (task.time != null && task.time!.length == 4) {
      hour = int.parse(task.time!.substring(0, 2));
      minute = int.parse(task.time!.substring(2, 4));
    }
    
    final startDate = DateTime(year, month, day, hour, minute);
    final endDate = startDate.add(const Duration(hours: 1)); // 1時間のイベント
    
    // iCal形式を生成
    final icalContent = _generateICalContent(task.content, startDate, endDate);
    
    // 一時ファイルに保存
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/event_${task.date}${task.time ?? ''}.ics');
    await file.writeAsString(icalContent);
    
    // 共有
    await Share.shareFiles(
      [file.path],
      text: 'カレンダーイベント: ${task.content}',
    );
    
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('エラーが発生しました: $e')),
    );
  }
}

String _generateICalContent(String summary, DateTime start, DateTime end) {
  final now = DateTime.now();
  
  final formatDateTime = (DateTime dt) {
    return dt.toUtc().toIso8601String()
      .replaceAll('-', '')
      .replaceAll(':', '')
      .split('.')[0] + 'Z';
  };
  
  return [
    'BEGIN:VCALENDAR',
    'VERSION:2.0',
    'PRODID:-//Namespace Task Manager//Flutter//EN',
    'BEGIN:VEVENT',
    'UID:${now.millisecondsSinceEpoch}@namespacetaskmanager',
    'DTSTAMP:${formatDateTime(now)}',
    'DTSTART:${formatDateTime(start)}',
    'DTEND:${formatDateTime(end)}',
    'SUMMARY:$summary',
    'END:VEVENT',
    'END:VCALENDAR'
  ].join('\r\n');
}
