import 'dart:convert';

import 'package:android_long_task/android_long_task.dart';

// describe data to be passed back from foreground task
class AppServiceData extends ServiceData {
  int progress = null;

  String toJson() {
    var jsonMap = {
      'progress': progress,
    };
    return jsonEncode(jsonMap);
  }

  static AppServiceData fromJson(Map<String, dynamic> json) {
    return AppServiceData()..progress = json['progress'] as int;
  }

  @override
  String get notificationTitle => 'long running task';

  @override
  String get notificationDescription => 'progress -> $progress (${DateTime.now()})';
}
