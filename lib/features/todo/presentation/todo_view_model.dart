import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_storage.dart';
import '../data/todo_repository_impl.dart';
import '../domain/models/todo_filter.dart';
import '../domain/models/todo_item.dart';
import '../domain/todo_repository.dart';
import 'todo_state.dart';

final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  final localStorage = LocalStorage();
  return TodoRepositoryImpl(localStorage);
});

final todoViewModelProvider =
    StateNotifierProvider<TodoViewModel, TodoState>((ref) {
      final repository = ref.watch(todoRepositoryProvider);
      return TodoViewModel(repository)..load();
    });

class RemovedTodo {
  const RemovedTodo({required this.item, required this.index});

  final TodoItem item;
  final int index;
}

class TodoViewModel extends StateNotifier<TodoState> {
  TodoViewModel(this._repository) : super(const TodoState());

  final TodoRepository _repository;

  Future<void> load() async {
    final items = await _repository.fetchTodos();
    state = state.copyWith(items: items, isLoading: false);
  }

  Future<void> addTodo(String title) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;

    final newItem = TodoItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: trimmed,
      isCompleted: false,
      createdAt: DateTime.now(),
    );

    final updated = [...state.items, newItem];
    await _saveAndSet(updated);
  }

  Future<void> toggleTodo(String id) async {
    final updated =
        state.items
            .map(
              (item) =>
                  item.id == id
                      ? item.copyWith(isCompleted: !item.isCompleted)
                      : item,
            )
            .toList();
    await _saveAndSet(updated);
  }

  Future<void> deleteTodo(String id) async {
    final updated = state.items.where((item) => item.id != id).toList();
    await _saveAndSet(updated);
  }

  Future<RemovedTodo?> removeTodoForUndo(String id) async {
    final targetIndex = state.items.indexWhere((item) => item.id == id);
    if (targetIndex < 0) return null;

    final removed = state.items[targetIndex];
    final updated = [...state.items]..removeAt(targetIndex);
    await _saveAndSet(updated);
    return RemovedTodo(item: removed, index: targetIndex);
  }

  Future<void> restoreRemovedTodo(RemovedTodo removedTodo) async {
    final updated = [...state.items];
    if (removedTodo.index >= 0 && removedTodo.index <= updated.length) {
      updated.insert(removedTodo.index, removedTodo.item);
    } else {
      updated.add(removedTodo.item);
    }
    await _saveAndSet(updated);
  }

  void setFilter(TodoFilter filter) {
    state = state.copyWith(filter: filter);
  }

  Future<void> _saveAndSet(List<TodoItem> items) async {
    await _repository.saveTodos(items);
    state = state.copyWith(items: items);
  }
}
