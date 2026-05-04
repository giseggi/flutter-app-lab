import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';
import '../domain/community_repository.dart';
import '../domain/models/community_models.dart';
import 'feed_controller.dart';

class FeedPage extends ConsumerWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(feedControllerProvider);
    final controller = ref.read(feedControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shokuba'),
        actions: [
          IconButton(
            tooltip: '새로고침',
            onPressed: controller.load,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: '로그아웃',
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openComposer(context, ref),
        icon: const Icon(Icons.edit_outlined),
        label: const Text('글쓰기'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _BoardSelector(
              selectedBoard: state.selectedBoard,
              onSelected: controller.selectBoard,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.load,
                child: _PostList(state: state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openComposer(BuildContext context, WidgetRef ref) async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const ComposePostPage()),
    );
    if (created == true && context.mounted) {
      await ref.read(feedControllerProvider.notifier).load();
    }
  }
}

class _BoardSelector extends StatelessWidget {
  const _BoardSelector({
    required this.selectedBoard,
    required this.onSelected,
  });

  final BoardKind selectedBoard;
  final ValueChanged<BoardKind> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: BoardKind.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final board = BoardKind.values[index];
          return ChoiceChip(
            label: Text(board.label),
            selected: selectedBoard == board,
            showCheckmark: false,
            onSelected: (_) => onSelected(board),
          );
        },
      ),
    );
  }
}

class _PostList extends StatelessWidget {
  const _PostList({required this.state});

  final FeedState state;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Icon(
            Icons.error_outline,
            size: 40,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 12),
          Center(child: Text(state.errorMessage!)),
        ],
      );
    }

    if (state.posts.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          SizedBox(height: 80),
          Icon(Icons.forum_outlined, size: 44),
          SizedBox(height: 12),
          Center(child: Text('아직 게시글이 없습니다')),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
      itemCount: state.posts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final post = state.posts[index];
        return _PostCard(post: post);
      },
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.post});

  final CommunityPost post;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => PostDetailPage(post: post)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _Badge(text: post.companyBadge),
                  const SizedBox(width: 6),
                  _Badge(text: post.jobBadge),
                  const Spacer(),
                  Text(_relativeTime(post.createdAt)),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                post.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                post.body,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.mode_comment_outlined, size: 18),
                  const SizedBox(width: 4),
                  Text('${post.commentCount}'),
                  const SizedBox(width: 16),
                  const Icon(Icons.trending_up, size: 18),
                  const SizedBox(width: 4),
                  Text('${post.reactionCount}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ComposePostPage extends ConsumerStatefulWidget {
  const ComposePostPage({super.key});

  @override
  ConsumerState<ComposePostPage> createState() => _ComposePostPageState();
}

class _ComposePostPageState extends ConsumerState<ComposePostPage> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  BoardKind _boardKind = BoardKind.all;
  String _jobBadge = '개발';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('게시글 작성')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<BoardKind>(
            initialValue: _boardKind,
            decoration: const InputDecoration(
              labelText: '게시판',
              prefixIcon: Icon(Icons.dashboard_outlined),
            ),
            items: BoardKind.values
                .map(
                  (kind) => DropdownMenuItem(
                    value: kind,
                    child: Text(kind.label),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _boardKind = value);
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _jobBadge,
            decoration: const InputDecoration(
              labelText: '직무 배지',
              prefixIcon: Icon(Icons.work_outline),
            ),
            items: const ['개발', '기획', '영업', '인사', '회계', '디자인']
                .map((job) => DropdownMenuItem(value: job, child: Text(job)))
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _jobBadge = value);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: '제목',
              prefixIcon: Icon(Icons.title),
            ),
            maxLength: 80,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bodyController,
            decoration: const InputDecoration(
              labelText: '본문',
              alignLabelWithHint: true,
            ),
            minLines: 8,
            maxLines: 12,
            maxLength: 1200,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _isSubmitting ? null : _submit,
            icon: _isSubmitting
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send_outlined),
            label: const Text('익명으로 게시'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목과 본문을 입력해 주세요')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ref.read(feedControllerProvider.notifier).createPost(
            PostDraft(
              title: title,
              body: body,
              boardKind: _boardKind,
              jobBadge: _jobBadge,
            ),
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('게시글을 등록하지 못했습니다')),
      );
    }
  }
}

class PostDetailPage extends ConsumerStatefulWidget {
  const PostDetailPage({super.key, required this.post});

  final CommunityPost post;

  @override
  ConsumerState<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends ConsumerState<PostDetailPage> {
  final _commentController = TextEditingController();
  late Future<List<CommunityComment>> _commentsFuture;

  @override
  void initState() {
    super.initState();
    _commentsFuture = _fetchComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<List<CommunityComment>> _fetchComments() {
    return ref.read(communityRepositoryProvider).fetchComments(widget.post.id);
  }

  @override
  Widget build(BuildContext context) {
    final repository = ref.read(communityRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('게시글'),
        actions: [
          IconButton(
            tooltip: '신고',
            onPressed: () => _report(
              repository,
              ReportTargetType.post,
              widget.post.id,
            ),
            icon: const Icon(Icons.flag_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _PostCard(post: widget.post),
                const SizedBox(height: 16),
                Text(
                  '댓글',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                FutureBuilder<List<CommunityComment>>(
                  future: _commentsFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final comments = snapshot.data!;
                    if (comments.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: Text('아직 댓글이 없습니다')),
                      );
                    }
                    return Column(
                      children: comments
                          .map((comment) => _CommentTile(comment: comment))
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: '익명으로 댓글 쓰기',
                        prefixIcon: Icon(Icons.reply_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: '보내기',
                    onPressed: _submitComment,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitComment() async {
    final body = _commentController.text.trim();
    if (body.isEmpty) return;

    final repository = ref.read(communityRepositoryProvider);
    await repository.createComment(postId: widget.post.id, body: body);
    _commentController.clear();
    setState(() => _commentsFuture = _fetchComments());
  }

  Future<void> _report(
    CommunityRepository repository,
    ReportTargetType targetType,
    String targetId,
  ) async {
    await repository.reportContent(
      targetType: targetType,
      targetId: targetId,
      reason: 'inappropriate',
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('신고가 접수되었습니다')),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});

  final CommunityComment comment;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Badge(text: comment.companyBadge),
                const SizedBox(width: 6),
                _Badge(text: comment.jobBadge),
                const Spacer(),
                Text(_relativeTime(comment.createdAt)),
              ],
            ),
            const SizedBox(height: 8),
            Text(comment.body),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colors.onSecondaryContainer,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

String _relativeTime(DateTime dateTime) {
  final diff = DateTime.now().difference(dateTime);
  if (diff.inMinutes < 1) return '방금';
  if (diff.inHours < 1) return '${diff.inMinutes}분 전';
  if (diff.inDays < 1) return '${diff.inHours}시간 전';
  return '${diff.inDays}일 전';
}
