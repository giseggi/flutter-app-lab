import '../domain/models/todo_filter.dart';
import '../domain/models/todo_item.dart';

class TodoState {
  const TodoState({
    this.items = const [],
    this.filter = TodoFilter.all,
    this.isLoading = true,
  });

  final List<TodoItem> items;
  final TodoFilter filter;
  final bool isLoading;

  int get totalCount => items.length;
  int get completedCount => items.where((item) => item.isCompleted).length;
  int get activeCount => totalCount - completedCount;
  double get completionRate =>
      totalCount == 0 ? 0 : completedCount / totalCount;

  List<TodoItem> get filteredItems {
    switch (filter) {
      case TodoFilter.active:
        return items.where((item) => !item.isCompleted).toList();
      case TodoFilter.completed:
        return items.where((item) => item.isCompleted).toList();
      case TodoFilter.all:
        return items;
    }
  }

  TodoState copyWith({
    List<TodoItem>? items,
    TodoFilter? filter,
    bool? isLoading,
  }) {
    return TodoState(
      items: items ?? this.items,
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
