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
  testWidgets('未ログインの場合は会社メールログインを表示する', (tester) async {
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
    expect(find.text('会社メール'), findsOneWidget);
    expect(find.text('認証リンクを送信'), findsOneWidget);
  });

  testWidgets('ログイン済みの場合はフィードを表示する', (tester) async {
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

    expect(find.text('全体'), findsWidgets);
    expect(find.text('職場のランチ補助について'), findsOneWidget);
  });

  test('会社メール検証は個人メールを拒否する', () {
    const validator = CompanyEmailValidator();

    expect(validator.validate('member@example.co.jp').isValid, isTrue);
    expect(validator.validate('member@gmail.com').isValid, isFalse);
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
        title: '職場のランチ補助について',
        body: '他社の福利厚生と比べてどうですか？',
        boardKind: BoardKind.all,
        companyBadge: '認証済み企業',
        jobBadge: '企画',
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
