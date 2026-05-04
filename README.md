# Shokuba

일본 직장인을 위한 회사 인증 기반 익명 커뮤니티 Flutter 앱입니다.

## 실행

```bash
fvm flutter pub get
fvm flutter run \
  --dart-define=SUPABASE_URL=<project-url> \
  --dart-define=SUPABASE_ANON_KEY=<publishable-or-anon-key>
```

Supabase 값이 없으면 로그인 화면에서 설정 안내를 표시하고, 피드 repository는 테스트/개발용 demo 구현으로 대체됩니다.

## 현재 MVP

- 회사 이메일 매직링크 로그인
- 개인 이메일 도메인 차단
- 익명 게시글 피드
- 전체/회사별/업계별/직군별 게시판
- 게시글 작성
- 댓글 조회/작성
- 게시글 신고
- Supabase repository와 테스트용 fake repository 분리

## 검증

```bash
fvm flutter analyze
fvm flutter test
```

Supabase DB 초안은 `docs/SUPABASE_SCHEMA.sql`을 참고합니다.
