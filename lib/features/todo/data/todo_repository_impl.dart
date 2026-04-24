import 'dart:convert';

import '../../../core/storage/local_storage.dart';
import '../domain/models/todo_item.dart';
import '../domain/todo_repository.dart';

class TodoRepositoryImpl implements TodoRepository {
  TodoRepositoryImpl(this._localStorage);

  final LocalStorage _localStorage;

  @override
  Future<List<TodoItem>> fetchTodos() async {
    final jsonString = await _localStorage.readTodoItemsJson();
    if (jsonString == null || jsonString.isEmpty) return [];

    final decoded = jsonDecode(jsonString) as List<dynamic>;
    return decoded
        .map((item) => TodoItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveTodos(List<TodoItem> items) async {
    final jsonString = jsonEncode(items.map((item) => item.toJson()).toList());
    await _localStorage.saveTodoItemsJson(jsonString);
  }
}
