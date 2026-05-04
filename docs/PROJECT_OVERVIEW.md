# Project Overview

Shokuba는 일본 직장인을 위한 회사 인증 기반 익명 커뮤니티 앱입니다. 사용자 UI는 일본어, 개발 문서는 한국어를 기본으로 합니다.

## 목표

- 회사 이메일 매직링크 인증
- 회사/직군 배지만 노출되는 익명 게시글
- 전체, 회사별, 업계별, 직군별 게시판
- 댓글과 신고 기능
- Supabase Auth/Postgres/RLS 기반 MVP

## 기술 스택

- Flutter
- Riverpod
- Supabase Flutter
- FVM

## 구조

```text
lib/
  app/
    app.dart
    app_config.dart
    app_theme.dart
  core/
    supabase/
      supabase_providers.dart
  features/
    auth/
      data/
      domain/
      presentation/
    feed/
      data/
      domain/
      presentation/
```

## 실행 흐름

1. `main.dart`가 `SUPABASE_URL`, `SUPABASE_ANON_KEY`를 읽는다.
2. 값이 있으면 `Supabase.initialize`를 실행한다.
3. `AuthController`가 현재 세션을 확인한다.
4. 세션이 없으면 회사 이메일 로그인 화면을 표시한다.
5. 세션이 있으면 게시판 피드를 표시한다.
6. 피드/게시글/댓글/신고는 `CommunityRepository`를 통해 처리한다.

## 구현 원칙

- 화면은 repository interface에만 의존한다.
- Supabase 구현과 테스트 fake 구현을 분리한다.
- 실명/닉네임은 UI에 노출하지 않는다.
- 개인 이메일 도메인은 클라이언트에서 1차 차단하고, 서버 정책으로도 보강한다.
