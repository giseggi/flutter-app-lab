# Shokuba

일본에서 일하는 한국인을 위한 회사 인증 기반 익명 직장·생활 커뮤니티 Flutter 앱입니다.

## 실행

의존성을 먼저 설치합니다.

```bash
fvm flutter pub get
```

### Chrome 앱 모드

개발 중 가장 일반적인 실행 방식입니다. Flutter가 Chrome을 직접 열고 디버깅 세션을 연결합니다.

```bash
fvm flutter run -d chrome
```

- Flutter CLI 프로세스가 살아있는 동안 앱이 실행됩니다.
- 터미널에서 `r`은 hot reload, `R`은 hot restart, `q`는 종료입니다.
- Chrome 디버깅과 hot reload 흐름이 가장 편합니다.
- 브라우저 주소와 포트는 Flutter가 자동으로 잡습니다.

### Web Server 모드

고정 URL로 앱을 띄우고 싶을 때 사용합니다.

```bash
fvm flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8080
```

브라우저에서 아래 주소로 접속합니다.

```text
http://127.0.0.1:8080
```

- Flutter CLI 프로세스가 살아있는 동안만 서버가 떠 있습니다.
- 터미널을 닫거나 프로세스를 종료하면 `http://127.0.0.1:8080`도 내려갑니다.
- 같은 네트워크나 다른 브라우저에서 고정 주소로 확인할 때 유용합니다.
- Chrome 앱 모드보다 디버깅 편의성은 낮습니다.

### Supabase 연결 실행

Supabase 인증/DB까지 연결하려면 실행 시 값을 넘깁니다.

```bash
fvm flutter run \
  --dart-define=SUPABASE_URL=<project-url> \
  --dart-define=SUPABASE_ANON_KEY=<publishable-or-anon-key>
```

Supabase 값이 없으면 로그인 화면에서 설정 안내를 표시하고, 피드 repository는 테스트/개발용 demo 구현으로 대체됩니다.

## 현재 MVP

- 일본 회사 이메일 매직링크 로그인
- 개인 이메일 도메인 차단
- 익명 게시글 피드
- 전체/회사생활/비자·노무/생활정보 게시판
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
