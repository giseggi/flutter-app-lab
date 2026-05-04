import 'models/community_models.dart';

abstract class CommunityRepository {
  Future<List<CommunityPost>> fetchPosts(BoardKind boardKind);

  Future<CommunityPost> createPost(PostDraft draft);

  Future<List<CommunityComment>> fetchComments(String postId);

  Future<CommunityComment> createComment({
    required String postId,
    required String body,
  });

  Future<void> reportContent({
    required ReportTargetType targetType,
    required String targetId,
    required String reason,
  });
}
