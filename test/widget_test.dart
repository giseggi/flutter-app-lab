import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shokuba/app/app.dart';
import 'package:shokuba/app/app_config.dart';
import 'package:shokuba/features/auth/domain/auth_repository.dart';
import 'package:shokuba/features/auth/domain/company_email_validator.dart';
import 'package:shokuba/features/auth/presentation/auth_controller.dart';
import 'package:shokuba/features/feed/domain/community_repository.dart';
import 'package:shokuba/features/feed/domain/models/community_models.dart';
import 'package:shokuba/features/feed/presentation/feed_controller.dart';

void main() {
  testWidgets('미로그인 상태에서는 회사 이메일 로그인을 표시한다', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(
            const AppConfig(supabaseUrl: '', supabaseAnonKey: ''),
          ),
        ],
        child: const MyApp(),
      ),
    );

    expect(find.text('Shokuba'), findsOneWidget);
    expect(find.text('회사 이메일'), findsOneWidget);
    expect(find.text('인증 링크 전송'), findsOneWidget);
  });

  testWidgets('로그인 상태에서는 한국어 게시판 피드를 표시한다', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(_SignedInAuthRepository()),
          communityRepositoryProvider.overrideWithValue(
            _FakeCommunityRepository(),
          ),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pump();

    expect(find.text('전체'), findsWidgets);
    expect(find.text('회사생활'), findsOneWidget);
    expect(find.text('비자·노무'), findsOneWidget);
    expect(find.text('생활정보'), findsOneWidget);
    expect(find.text('일본 회사 회식 문화, 어디까지 맞춰야 할까요?'), findsOneWidget);
  });

  test('회사 이메일 검증은 개인 이메일을 거부한다', () {
    const validator = CompanyEmailValidator();

    expect(validator.validate('member@example.co.jp').isValid, isTrue);
    expect(validator.validate('member@gmail.com').isValid, isFalse);
    expect(
      validator.validate('member@gmail.com').errorMessage,
      '개인 이메일로는 가입할 수 없습니다',
    );
  });
}

class _SignedInAuthRepository implements AuthRepository {
  @override
  bool get isConfigured => true;

  @override
  bool get isSignedIn => true;

  @override
  Stream<bool> get sessionChanges => const Stream<bool>.empty();

  @override
  Future<void> sendMagicLink(String email) async {}

  @override
  Future<void> signOut() async {}
}

class _FakeCommunityRepository implements CommunityRepository {
  @override
  Future<List<CommunityPost>> fetchPosts(BoardKind boardKind) async {
    return [
      CommunityPost(
        id: 'post-1',
        title: '일본 회사 회식 문화, 어디까지 맞춰야 할까요?',
        body: '입사한 지 얼마 안 됐는데 회식 참석 압박이 생각보다 큽니다.',
        boardKind: BoardKind.all,
        companyBadge: '인증된 회사',
        jobBadge: '기획',
        createdAt: DateTime(2026, 5, 4),
      ),
    ];
  }

  @override
  Future<CommunityPost> createPost(PostDraft draft) {
    throw UnimplementedError();
  }

  @override
  Future<List<CommunityComment>> fetchComments(String postId) async => const [];

  @override
  Future<CommunityComment> createComment({
    required String postId,
    required String body,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> reportContent({
    required ReportTargetType targetType,
    required String targetId,
    required String reason,
  }) async {}
}
