import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/todo_filter.dart';
import 'todo_state.dart';
import 'todo_view_model.dart';

class TodoPage extends ConsumerStatefulWidget {
  const TodoPage({super.key});

  @override
  ConsumerState<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends ConsumerState<TodoPage> {
  final _textController = TextEditingController();
  final _inputFocusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(todoViewModelProvider);
    final viewModel = ref.read(todoViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Board'),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildKpiRow(context, state),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        focusNode: _inputFocusNode,
                        controller: _textController,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          hintText: '새 할 일을 입력하고 Enter',
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.flash_on_outlined),
                        ),
                        onSubmitted: (_) => _submit(viewModel),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () => _submit(viewModel),
                      icon: const Icon(Icons.add),
                      label: const Text('추가'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<TodoFilter>(
              segments: const [
                ButtonSegment(value: TodoFilter.all, label: Text('전체')),
                ButtonSegment(value: TodoFilter.active, label: Text('미완료')),
                ButtonSegment(value: TodoFilter.completed, label: Text('완료')),
              ],
              selected: {state.filter},
              onSelectionChanged: (selected) {
                viewModel.setFilter(selected.first);
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child:
                  state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : state.filteredItems.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                        itemCount: state.filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = state.filteredItems[index];
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Card(
                              elevation: 0,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 2,
                                ),
                                leading: InkWell(
                                  borderRadius: BorderRadius.circular(24),
                                  onTap: () => viewModel.toggleTodo(item.id),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Checkbox(
                                      value: item.isCompleted,
                                      onChanged:
                                          (_) => viewModel.toggleTodo(item.id),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  item.title,
                                  style: TextStyle(
                                    fontWeight:
                                        item.isCompleted
                                            ? FontWeight.w400
                                            : FontWeight.w600,
                                    color:
                                        item.isCompleted
                                            ? Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant
                                            : Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                    decoration:
                                        item.isCompleted
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                  ),
                                ),
                                trailing: IconButton(
                                  tooltip: '삭제',
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed:
                                      () => _deleteWithUndo(viewModel, item.id),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiRow(BuildContext context, TodoState state) {
    final rate = (state.completionRate * 100).toStringAsFixed(0);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _KpiChip(label: '전체', value: '${state.totalCount}'),
        _KpiChip(label: '진행중', value: '${state.activeCount}'),
        _KpiChip(label: '완료', value: '${state.completedCount}'),
        _KpiChip(label: '완료율', value: '$rate%'),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inbox_outlined, size: 44),
          const SizedBox(height: 8),
          const Text('아직 할 일이 없습니다'),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () {
              _inputFocusNode.requestFocus();
            },
            child: const Text('첫 할 일 추가하기'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteWithUndo(TodoViewModel viewModel, String id) async {
    final removed = await viewModel.removeTodoForUndo(id);
    if (!mounted || removed == null) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('할 일을 삭제했어요.'),
          action: SnackBarAction(
            label: '실행취소',
            onPressed: () {
              viewModel.restoreRemovedTodo(removed);
            },
          ),
        ),
      );
  }

  Future<void> _submit(TodoViewModel viewModel) async {
    final before = _textController.text;
    await viewModel.addTodo(_textController.text);
    if (!mounted) return;
    if (before.trim().isNotEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            duration: Duration(milliseconds: 900),
            content: Text('할 일을 추가했어요.'),
          ),
        );
    }
    _textController.clear();
    _inputFocusNode.requestFocus();
  }
}

class _KpiChip extends StatelessWidget {
  const _KpiChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
