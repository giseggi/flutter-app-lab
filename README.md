# app_test

Flutter 입문용 백엔드 개발자 템플릿입니다.

## FVM 기반 실행 방법

### 1) FVM 설치 (macOS)

```bash
brew tap leoafarias/fvm
brew install fvm
```

### 2) 프로젝트 SDK 고정

프로젝트 루트에 `.fvmrc`가 포함되어 있습니다.

```bash
cd /Users/kylee/workspace/app-test
fvm use
```

### 3) 의존성 설치 및 실행

```bash
fvm flutter pub get
fvm flutter run
```

## 참고

- VSCode/Cursor 설정은 `.vscode/settings.json`에 포함되어 있습니다.
- IDE가 프로젝트의 SDK를 `.fvm/flutter_sdk`로 사용하도록 맞춰둔 상태입니다.

## TODO (네이티브 실행 준비)

- [ ] Android Studio 설치
- [ ] Android SDK 설치 및 경로 확인 (`flutter doctor`)
- [ ] Android 에뮬레이터 1개 생성 후 부팅
- [ ] Android 라이선스 동의 (`flutter doctor --android-licenses`)
- [ ] Xcode 설치 (App Store)
- [ ] Xcode 초기 설정 완료 (`xcode-select`, `xcodebuild -runFirstLaunch`)
- [ ] CocoaPods 설치 (`brew install cocoapods`)
- [ ] `fvm flutter doctor`에서 Android/Xcode 항목 초록 상태 확인

## 현재 포함 기능

- Riverpod 기반 로그인 상태관리
- Dio 기반 로그인 API 호출 (`https://reqres.in/api/login`)
- SharedPreferences 토큰 저장
