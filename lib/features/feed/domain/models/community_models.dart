enum BoardKind {
  all('all', '全体'),
  company('company', '会社別'),
  industry('industry', '業界別'),
  job('job', '職種別');

  const BoardKind(this.databaseValue, this.label);

  final String databaseValue;
  final String label;

  static BoardKind fromDatabaseValue(String value) {
    return BoardKind.values.firstWhere(
      (kind) => kind.databaseValue == value,
      orElse: () => BoardKind.all,
    );
  }
}

enum ReportTargetType {
  post('post'),
  comment('comment');

  const ReportTargetType(this.databaseValue);

  final String databaseValue;
}

class Company {
  const Company({
    required this.id,
    required this.name,
    required this.emailDomain,
    required this.industry,
  });

  final String id;
  final String name;
  final String emailDomain;
  final String industry;
}

class CommunityPost {
  const CommunityPost({
    required this.id,
    required this.title,
    required this.body,
    required this.boardKind,
    required this.companyBadge,
    required this.jobBadge,
    required this.createdAt,
    this.commentCount = 0,
    this.reactionCount = 0,
  });

  final String id;
  final String title;
  final String body;
  final BoardKind boardKind;
  final String companyBadge;
  final String jobBadge;
  final DateTime createdAt;
  final int commentCount;
  final int reactionCount;

  factory CommunityPost.fromMap(Map<String, dynamic> map) {
    return CommunityPost(
      id: map['id'] as String,
      title: map['title'] as String,
      body: map['body'] as String,
      boardKind: BoardKind.fromDatabaseValue(map['board_kind'] as String),
      companyBadge: map['company_badge'] as String? ?? '認証済み',
      jobBadge: map['job_badge'] as String? ?? '未設定',
      createdAt: DateTime.parse(map['created_at'] as String),
      commentCount: map['comment_count'] as int? ?? 0,
      reactionCount: map['reaction_count'] as int? ?? 0,
    );
  }
}

class PostDraft {
  const PostDraft({
    required this.title,
    required this.body,
    required this.boardKind,
    required this.jobBadge,
  });

  final String title;
  final String body;
  final BoardKind boardKind;
  final String jobBadge;
}

class CommunityComment {
  const CommunityComment({
    required this.id,
    required this.postId,
    required this.body,
    required this.companyBadge,
    required this.jobBadge,
    required this.createdAt,
  });

  final String id;
  final String postId;
  final String body;
  final String companyBadge;
  final String jobBadge;
  final DateTime createdAt;

  factory CommunityComment.fromMap(Map<String, dynamic> map) {
    return CommunityComment(
      id: map['id'] as String,
      postId: map['post_id'] as String,
      body: map['body'] as String,
      companyBadge: map['company_badge'] as String? ?? '認証済み',
      jobBadge: map['job_badge'] as String? ?? '未設定',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
