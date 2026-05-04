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
        companyBadge: '인증된 회사',
        jobBadge: '미설정',
      );
    }

    final company = row['companies'];
    final companyName =
        company is Map<String, dynamic> ? company['name'] as String? : null;

    return _BadgeContext(
      companyBadge: companyName ?? '인증된 회사',
      jobBadge: row['job_badge'] as String? ?? '미설정',
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
            title: '일본 회사 회식 문화, 어디까지 맞춰야 할까요?',
            body: '입사한 지 얼마 안 됐는데 회식 참석 압박이 생각보다 큽니다. 다들 어떻게 조율하시나요?',
            boardKind: BoardKind.all,
            companyBadge: '인증된 회사',
            jobBadge: '개발',
            createdAt: DateTime.now().subtract(const Duration(minutes: 18)),
            commentCount: 3,
          ),
          CommunityPost(
            id: 'demo-2',
            title: '기술·인문지식 비자 갱신 준비, 회사 서류는 언제 요청하세요?',
            body: '재류기간 갱신이 3개월 정도 남았습니다. 재직증명서와 원천징수표 준비 타이밍이 궁금합니다.',
            boardKind: BoardKind.visaLabor,
            companyBadge: '인증된 회사',
            jobBadge: '기획',
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
            commentCount: 1,
          ),
          CommunityPost(
            id: 'demo-3',
            title: '도쿄에서 전세 없이 이사할 때 초기비용 줄이는 팁 있나요?',
            body: '보증회사 비용과 사례금이 부담됩니다. 한국인도 상담하기 편한 부동산 경험 공유 부탁드립니다.',
            boardKind: BoardKind.life,
            companyBadge: '인증된 회사',
            jobBadge: '영업',
            createdAt: DateTime.now().subtract(const Duration(hours: 4)),
            commentCount: 2,
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
      companyBadge: '인증된 회사',
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
      companyBadge: '인증된 회사',
      jobBadge: '개발',
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
