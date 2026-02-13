---
name: secure-code
description: Security best practices for Flutter app development based on OWASP Mobile Top 10. Covers credential security, supply chain, authentication, communication, and privacy controls.
user-invocable: false
---

# Secure Code (Flutter)

OWASP Mobile Top 10 및 Flutter 특화 보안 원칙을 적용한다. 모든 코드는 보안을 기본으로 고려하여 작성한다.

## 핵심 원칙

1. **Defense in Depth**: 다중 방어 계층을 적용한다
2. **Least Privilege**: 최소 권한 원칙을 따른다
3. **Fail Secure**: 실패 시 안전한 상태로 전환한다
4. **Never Trust Client**: 클라이언트 검증은 UX용이며, 보안은 서버에서 처리한다

## M1: Improper Credential Usage (자격 증명 관리)

### 금지 사항
- API 키, 시크릿, 토큰을 소스 코드에 하드코딩하지 않는다
- 자격 증명을 'SharedPreferences'에 저장하지 않는다
- 자격 증명을 로그에 출력하지 않는다
- '.env' 파일을 Git에 커밋하지 않는다

### 필수 사항
- 민감 데이터는 'flutter_secure_storage' 사용 (iOS Keychain / Android Keystore)
- API 키는 BFF(Backend For Frontend) 패턴으로 서버에서 관리
- 토큰은 짧은 수명(short-lived)으로 설정하고 refresh token으로 갱신

~~~dart
// Good
final secureStorage = FlutterSecureStorage();
await secureStorage.write(key: 'auth_token', value: token);
final token = await secureStorage.read(key: 'auth_token');

// Bad
final prefs = await SharedPreferences.getInstance();
prefs.setString('auth_token', token); // 평문 저장
~~~

### .gitignore 필수 항목
~~~
*.env
*.jks
*.keystore
google-services.json
GoogleService-Info.plist
~~~

## M2: Inadequate Supply Chain Security (공급망 보안)

### 패키지 선택 기준
- pub.dev에서 **Verified Publisher** 확인
- **Popularity Score** 높은 패키지 우선
- 최근 업데이트 일자 확인 (6개월 이상 방치된 패키지 주의)
- 의존성 수를 최소화한다

### 패키지 관리
- 'pubspec.lock'을 반드시 Git에 커밋한다
- 버전을 고정하거나 '^' (caret syntax)로 범위를 제한한다
- 정기적으로 'flutter pub outdated'로 업데이트 확인
- 'flutter pub audit'로 보안 취약점 스캔

~~~yaml
# Good - 버전 범위 제한
dependencies:
  flutter_secure_storage: ^9.0.0

# Bad - any 또는 범위 없음
dependencies:
  some_package: any
~~~

## M3: Insecure Authentication & Authorization (인증/인가)

### 인증
- OAuth 2.0 / OIDC 프로토콜 사용
- 토큰 기반 인증 (JWT) 사용 시 서버에서 검증
- 바이오메트릭 인증은 **비대칭 키 기반**으로 구현 (TouchID 단독 의존 금지)
- 세션 타임아웃 구현

### 인가
- 클라이언트에서 인가 로직을 하지 않는다 (서버에서 처리)
- 클라이언트 권한 체크는 UX 목적으로만 사용
- Role-Based Access Control(RBAC) 적용

### 비밀번호 처리
- 비밀번호를 로컬에 저장하지 않는다
- 비밀번호 입력 UI에서 'obscureText: true' 사용
- 비밀번호 강도 검증은 클라이언트+서버 모두 적용

~~~dart
// Good - 안전한 비밀번호 필드
TextField(
  obscureText: true,
  autocorrect: false,
  enableSuggestions: false,
  decoration: const InputDecoration(labelText: 'Password'),
)
~~~

## M5: Insecure Communication (안전하지 않은 통신)

### HTTPS 필수
- 모든 API 통신에 HTTPS 사용
- HTTP fallback을 허용하지 않는다
- Certificate Pinning 적용 고려

~~~dart
// Certificate pinning 예시
final client = HttpClient()
  ..badCertificateCallback = (cert, host, port) => false; // 잘못된 인증서 거부
~~~

### 네트워크 보안 설정
- Android: 'network_security_config.xml'에서 cleartext 차단
- iOS: ATS(App Transport Security) 활성화 유지

~~~xml
<!-- android/app/src/main/res/xml/network_security_config.xml -->
<network-security-config>
    <base-config cleartextTrafficPermitted="false" />
</network-security-config>
~~~

### 데이터 전송
- 민감 데이터를 URL 파라미터에 포함하지 않는다
- 요청/응답 바디에 불필요한 민감 정보를 포함하지 않는다
- API 응답에서 필요한 데이터만 수신한다

## M6: Inadequate Privacy Controls (부적절한 프라이버시 제어)

### 데이터 수집 최소화
- 기능에 필요한 최소한의 데이터만 수집한다
- 사용자 동의 없이 데이터를 수집하지 않는다
- 데이터 수집 목적을 명확히 한다

### 로깅 보안
- 'print()' 사용 금지 — 'avoid_print' 린트 규칙 활성화
- 릴리스 빌드에서 모든 디버그 로그 제거
- 로그에 개인 정보(이메일, 전화번호 등) 출력 금지
- Logger 패키지 사용 시 릴리스 빌드에서 로그 레벨 조정

~~~dart
// Good - 릴리스 빌드에서 안전
import 'package:logger/logger.dart';
final logger = Logger(
  level: kReleaseMode ? Level.warning : Level.debug,
);

// Bad
print('User email: ${user.email}'); // 민감 정보 로깅
debugPrint('Token: $authToken');     // 토큰 로깅
~~~

### 로컬 데이터 보안
- Hive 박스에 민감 데이터 저장 시 'encryptedBox' 사용
- 앱 삭제 시 데이터가 완전히 제거되는지 확인
- 백그라운드 스냅샷에서 민감 화면 숨기기

~~~dart
// Good - Hive 암호화 박스
final encryptionKey = await secureStorage.read(key: 'hive_key');
final box = await Hive.openBox('secrets',
  encryptionCipher: HiveAesCipher(base64Decode(encryptionKey!)),
);
~~~

## 코드 난독화 (Obfuscation)

- 릴리스 빌드에서 코드 난독화 적용

~~~bash
flutter build apk --obfuscate --split-debug-info=build/debug-info
flutter build ios --obfuscate --split-debug-info=build/debug-info
~~~

## 입력 검증

- 모든 사용자 입력을 검증한다
- 입력 길이를 제한한다
- 특수 문자를 적절히 처리한다 (SQL Injection, XSS 방지)
- 서버에서도 동일한 검증을 수행한다 (이중 검증)

~~~dart
// Good - 입력 검증
String? validateTitle(String? value) {
  if (value == null || value.trim().isEmpty) {
    return '제목을 입력해주세요';
  }
  if (value.length > 200) {
    return '제목은 200자 이하로 입력해주세요';
  }
  return null;
}
~~~

## 앱 무결성 검사

- 루팅/탈옥 감지 고려 (민감 앱의 경우)
- 디버거 감지 (릴리스 빌드에서)
- 앱 서명 검증

## 보안 테스트

### 개발 단계
- 정적 분석: 'flutter analyze' + 커스텀 린트 규칙
- 의존성 검사: 'flutter pub audit'
- 코드 리뷰에서 보안 체크리스트 적용

### 릴리스 전
- OWASP MASVS 기준 검증
- 모바일 보안 스캐너 (MobSF) 사용
- API 인터셉트 프록시 (Burp Suite) 테스트
- 주요 릴리스 전 펜테스트 수행

## 보안 체크리스트 요약

| 항목 | 상태 |
|------|------|
| 하드코딩된 시크릿 없음 | [ ] |
| flutter_secure_storage 사용 | [ ] |
| HTTPS 전용 통신 | [ ] |
| print() 사용 안 함 | [ ] |
| 로그에 민감 정보 없음 | [ ] |
| pubspec.lock Git 커밋 | [ ] |
| 코드 난독화 적용 (릴리스) | [ ] |
| 입력 검증 적용 | [ ] |
| .gitignore에 시크릿 파일 포함 | [ ] |
| Hive 암호화 박스 사용 (민감 데이터) | [ ] |
