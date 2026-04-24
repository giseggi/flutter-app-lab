# Project Overview

이 프로젝트는 Flutter 입문용 템플릿이며, 백엔드 개발자가 모바일 앱 기본 구조를 빠르게 익히기 위한 TODO 앱 샘플입니다.

## 목적

- Flutter 프로젝트의 기본 구조 이해
- 기능 단위(feature) 개발 방식 경험
- TODO 입력부터 저장/필터링까지 전체 흐름 파악

## 기술 스택

- Flutter
- Riverpod (상태관리)
- Dio (HTTP 통신)
- SharedPreferences (로컬 저장소)
- FVM (Flutter SDK 버전 관리)

## 디렉터리 구조

```text
lib/
  main.dart
  app/
    app.dart
  core/
    network/
      dio_client.dart
    storage/
      local_storage.dart
  features/
    auth/
      ...
    todo/
      data/
        todo_repository_impl.dart
      domain/
        todo_repository.dart
        models/
          todo_filter.dart
          todo_item.dart
      presentation/
        todo_page.dart
        todo_state.dart
        todo_view_model.dart
```

## 레이어별 역할

- `presentation`
  - 화면 렌더링, 사용자 입력 처리, 로딩/에러/성공 상태 표시
- `domain`
  - 비즈니스 관점 인터페이스와 모델 정의
- `data`
  - API 호출 및 저장소 연동 구현
- `core`
  - 여러 feature에서 공통으로 사용하는 네트워크/스토리지 코드

## 실행 흐름 (TODO)

1. `main.dart`에서 `ProviderScope`로 앱 시작
2. `app.dart`에서 첫 화면으로 `TodoPage` 노출
3. `TodoViewModel.load()`가 저장된 목록을 로컬에서 읽어 상태 복원
4. 사용자가 항목 추가/완료 토글/삭제를 수행
5. 상태 변경 시 `TodoRepository`를 통해 목록을 JSON으로 저장
6. `TodoState`의 필터값에 따라 화면에 표시되는 목록이 변경

## UI/UX 개선 포인트

- 상단 KPI 칩으로 `전체/진행중/완료/완료율`을 즉시 확인
- 빠른 캡처 입력바로 Enter 중심 입력 플로우 제공
- 삭제 시 스낵바 `실행취소(Undo)`로 실수 복구 지원
- 완료된 항목은 시각 강조를 낮춰 진행중 작업에 집중

## 아키텍처 포인트

- 기능 기준 폴더 분리(`features/todo`)로 확장 용이
- UI 코드와 API 코드 분리로 유지보수 용이
- 같은 패턴으로 `auth`, `profile` 같은 feature 추가 가능

## 실행 방법

```bash
fvm use
fvm flutter pub get
fvm flutter run -d chrome
```

네이티브(Android/iOS) 실행은 SDK 및 Xcode 설정이 필요하며, 상세 항목은 `README.md`의 TODO 섹션을 참고합니다.
