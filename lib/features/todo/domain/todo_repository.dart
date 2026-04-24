import 'models/todo_item.dart';

abstract class TodoRepository {
  Future<List<TodoItem>> fetchTodos();
  Future<void> saveTodos(List<TodoItem> items);
}
