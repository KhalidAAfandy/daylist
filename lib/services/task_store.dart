import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/models/task.dart';

class TaskStore {
  static const key = 'tasks.v1';

  Future<List<Task>> load() async {
    final preferences = await SharedPreferences.getInstance();
    final source = preferences.getString(key);
    if (source == null) return [];
    return (jsonDecode(source) as List)
        .map((item) => Task.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> save(List<Task> tasks) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      key,
      jsonEncode(tasks.map((task) => task.toJson()).toList()),
    );
    if (!saved) throw StateError('Could not save tasks');
  }
}
