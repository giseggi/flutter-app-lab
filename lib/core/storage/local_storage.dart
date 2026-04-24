import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const _tokenKey = 'auth_token';
  static const _todoItemsKey = 'todo_items_json';

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> readToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<void> saveTodoItemsJson(String jsonString) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_todoItemsKey, jsonString);
  }

  Future<String?> readTodoItemsJson() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_todoItemsKey);
  }
}
