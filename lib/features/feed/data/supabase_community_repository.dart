import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/community_repository.dart';
import '../domain/models/community_models.dart';

class SupabaseCommunityRepository implements CommunityRepository {
  const SupabaseCommunityRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<CommunityPost>> fetchPosts(BoardKind boardKind) async {
    final query = _client
        .from('posts')
        .select()
        .eq('board_kind', boardKind.databaseValue)
        .order('created_at', ascending: false);
    final rows = await query;
    return rows.map(CommunityPost.fromMap).toList();
  }

  @override
  Future<CommunityPost> createPost(PostDraft draft) async {
    final userId = _requireUserId();
    final badges = await _fetchBadgeContext(userId);
    final row = await _client
        .from('posts')
        .insert({
          'author_id': userId,
          'title': draft.title,
          'body': draft.body,
          'board_kind': draft.boardKind.databaseValue,
          'company_badge': badges.companyBadge,
          'job_badge': draft.jobBadge,
        })
        .select()
        .single();
    return CommunityPost.fromMap(row);
  }

  @override
  Future<List<CommunityComment>> fetchComments(String postId) async {
    final rows = await _client
        .from('comments')
        .select()
        .eq('post_id', postId)
        .order('created_at');
    return rows.map(CommunityComment.fromMap).toList();
  }

  @override
  Future<CommunityComment> createComment({
    required String postId,
    required String body,
  }) async {
    final userId = _requireUserId();
    final badges = await _fetchBadgeContext(userId);
    final row = await _client
        .from('comments')
        .insert({
          'post_id': postId,
          'author_id': userId,
          'body': body,
          'company_badge': badges.companyBadge,
          'job_badge': badges.jobBadge,
        })
        .select()
        .single();
    return CommunityComment.fromMap(row);
  }

  @override
  Future<void> reportContent({
    required ReportTargetType targetType,
    required String targetId,
    required String reason,
  }) async {
    final userId = _requireUserId();
    await _client.from('reports').insert({
      'reporter_id': userId,
      'target_type': targetType.databaseValue,
      'target_id': targetId,
      'reason': reason,
    });
  }

  String _requireUserId() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('Authenticated user is required.');
    }
    return userId;
  }

  Future<_BadgeContext> _fetchBadgeContext(String userId) async {
    final row = await _client
        .from('profiles')
        .select('job_badge, companies(name)')
        .eq('id', userId)
        .maybeSingle();

    if (row == null) {
      return const _BadgeContext(
        companyBadge: '認証済み企業',
        jobBadge: '未設定',
      );
    }

    final company = row['companies'];
    final companyName =
        company is Map<String, dynamic> ? company['name'] as String? : null;

    return _BadgeContext(
      companyBadge: companyName ?? '認証済み企業',
      jobBadge: row['job_badge'] as String? ?? '未設定',
    );
  }
}

class _BadgeContext {
  const _BadgeContext({
    required this.companyBadge,
    required this.jobBadge,
  });

  final String companyBadge;
  final String jobBadge;
}

class DemoCommunityRepository implements CommunityRepository {
  DemoCommunityRepository()
      : _posts = [
          CommunityPost(
            id: 'demo-1',
            title: '新卒研修の内容、どこまで実務に近いですか？',
            body: '配属前研修が長めなのですが、現場とのギャップが気になっています。',
            boardKind: BoardKind.all,
            companyBadge: '認証済み企業',
            jobBadge: 'エンジニア',
            createdAt: DateTime.now().subtract(const Duration(minutes: 18)),
            commentCount: 3,
          ),
          CommunityPost(
            id: 'demo-2',
            title: 'リモート勤務の実態を知りたい',
            body: '制度上は週3リモートですが、部署によって差が大きいです。',
            boardKind: BoardKind.company,
            companyBadge: '認証済み企業',
            jobBadge: '企画',
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
            commentCount: 1,
          ),
        ];

  final List<CommunityPost> _posts;
  final Map<String, List<CommunityComment>> _comments = {};

  @override
  Future<List<CommunityPost>> fetchPosts(BoardKind boardKind) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return _posts.where((post) => post.boardKind == boardKind).toList();
  }

  @override
  Future<CommunityPost> createPost(PostDraft draft) async {
    final post = CommunityPost(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: draft.title,
      body: draft.body,
      boardKind: draft.boardKind,
      companyBadge: '認証済み企業',
      jobBadge: draft.jobBadge,
      createdAt: DateTime.now(),
    );
    _posts.insert(0, post);
    return post;
  }

  @override
  Future<List<CommunityComment>> fetchComments(String postId) async {
    return _comments[postId] ?? const [];
  }

  @override
  Future<CommunityComment> createComment({
    required String postId,
    required String body,
  }) async {
    final comment = CommunityComment(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      postId: postId,
      body: body,
      companyBadge: '認証済み企業',
      jobBadge: 'エンジニア',
      createdAt: DateTime.now(),
    );
    _comments.putIfAbsent(postId, () => []).add(comment);
    return comment;
  }

  @override
  Future<void> reportContent({
    required ReportTargetType targetType,
    required String targetId,
    required String reason,
  }) async {}
}
