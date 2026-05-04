import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../data/supabase_community_repository.dart';
import '../domain/community_repository.dart';
import '../domain/models/community_models.dart';

final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return DemoCommunityRepository();
  return SupabaseCommunityRepository(client);
});

final feedControllerProvider =
    StateNotifierProvider<FeedController, FeedState>((ref) {
  final repository = ref.watch(communityRepositoryProvider);
  return FeedController(repository)..load();
});

class FeedState {
  const FeedState({
    this.selectedBoard = BoardKind.all,
    this.posts = const [],
    this.isLoading = true,
    this.errorMessage,
  });

  final BoardKind selectedBoard;
  final List<CommunityPost> posts;
  final bool isLoading;
  final String? errorMessage;

  FeedState copyWith({
    BoardKind? selectedBoard,
    List<CommunityPost>? posts,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FeedState(
      selectedBoard: selectedBoard ?? this.selectedBoard,
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class FeedController extends StateNotifier<FeedState> {
  FeedController(this._repository) : super(const FeedState());

  final CommunityRepository _repository;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final posts = await _repository.fetchPosts(state.selectedBoard);
      state = state.copyWith(posts: posts, isLoading: false);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '게시글을 불러오지 못했습니다',
      );
    }
  }

  Future<void> selectBoard(BoardKind boardKind) async {
    if (boardKind == state.selectedBoard) return;
    state = state.copyWith(selectedBoard: boardKind, posts: const []);
    await load();
  }

  Future<void> createPost(PostDraft draft) async {
    final post = await _repository.createPost(draft);
    if (post.boardKind == state.selectedBoard) {
      state = state.copyWith(posts: [post, ...state.posts]);
    }
  }
}
