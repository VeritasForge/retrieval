---
name: flutter-patterns
description: Flutter idiomatic patterns and best practices. Ensures Flutter code follows official conventions with efficient widget composition, state management, and platform-aware development.
user-invocable: false
---

# Flutter Idiomatic Patterns

Flutter 코드를 작성할 때 반드시 아래 원칙을 따른다.

## Widget 설계 원칙

### 작고 집중된 Widget
- 각 Widget은 하나의 시각적/기능적 책임만 가진다
- `build()` 메서드가 50줄을 넘기면 분리를 고려한다
- 재사용 가능한 Widget은 별도 파일로 분리한다

### Widget 구성 (Composition over Inheritance)
- Widget 상속보다 조합(composition)을 선호한다
- `StatelessWidget`을 기본으로 사용하고, 상태가 필요할 때만 `StatefulWidget` 또는 상태관리 솔루션을 사용한다

### const Constructor
- 가능한 모든 Widget에 `const` constructor를 사용한다
- `const` Widget은 리빌드 시 재생성되지 않아 성능에 유리하다

```dart
// Good
class AppTitle extends StatelessWidget {
  const AppTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('Retrieval');
  }
}

// Bad - const를 사용하지 않음
class AppTitle extends StatelessWidget {
  AppTitle({super.key}); // const 누락
  // ...
}
```

## 상태 관리 (Riverpod)

이 프로젝트는 **Riverpod**을 상태 관리 솔루션으로 사용한다.

### Provider 설계 원칙
- Provider는 하나의 상태 단위만 관리한다
- `StateNotifier`/`Notifier` 사용 시 immutable state를 반환한다
- `AsyncNotifier`로 비동기 상태를 관리한다
- `ref.watch()`로 반응형 의존성을 구성한다
- `ref.read()`는 이벤트 핸들러에서만 사용한다

```dart
// Good - ref.watch는 build 내에서
@override
Widget build(BuildContext context, WidgetRef ref) {
  final state = ref.watch(reviewProvider);
  return state.when(
    data: (reviews) => ReviewList(reviews: reviews),
    loading: () => const CircularProgressIndicator(),
    error: (e, _) => ErrorWidget(error: e),
  );
}

// Good - ref.read는 이벤트 핸들러에서
onPressed: () => ref.read(reviewProvider.notifier).addReview(review),
```

### Provider 구조
- Feature별로 Provider를 구성한다
- Domain layer의 UseCase를 Provider로 노출한다
- Repository 인터페이스를 Provider로 주입한다 (DI)

```dart
// Repository provider (DI)
final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepositoryImpl(
    localDataSource: ref.read(reviewLocalDataSourceProvider),
  );
});

// UseCase provider
final getReviewsUseCaseProvider = Provider<GetReviews>((ref) {
  return GetReviews(ref.read(reviewRepositoryProvider));
});
```

## 레이아웃 Best Practices

### SizedBox vs Container
- 고정 크기 공백에는 `SizedBox` 사용 (`Container` 아님)
- `SizedBox`는 const constructor를 지원한다

```dart
// Good
const SizedBox(height: 16),
const SizedBox(width: 8),

// Bad
Container(height: 16), // SizedBox가 더 적합
```

### Padding과 Margin
- 단일 방향 padding은 `EdgeInsets.only()` 사용
- 대칭 padding은 `EdgeInsets.symmetric()` 사용
- 일관된 spacing 상수를 정의하여 사용

```dart
abstract class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}
```

## 네비게이션

- `GoRouter` 또는 `Navigator 2.0` 패턴 사용
- 딥링크와 웹 URL을 고려한 라우팅 설계
- 라우트 경로는 상수로 관리

## 테마와 스타일링

### Theme 활용
- 하드코딩 색상/폰트 대신 `Theme.of(context)` 사용
- Material 3 (`useMaterial3: true`) 기반 테마 설계
- 커스텀 테마 확장은 `ThemeExtension` 사용

```dart
// Good
Text(
  'Title',
  style: Theme.of(context).textTheme.headlineMedium,
),

// Bad
Text(
  'Title',
  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
),
```

### 반응형 레이아웃
- `MediaQuery`와 `LayoutBuilder`로 반응형 UI 구성
- 화면 크기별 breakpoint 상수 정의
- `Flexible`, `Expanded`, `FractionallySizedBox` 활용

## 성능 최적화

### Widget Rebuild 최소화
- `setState()` 호출을 최소화하고 영향 범위를 좁힌다
- `const` Widget을 적극 활용한다
- 리스트는 `ListView.builder()`/`ListView.separated()` 사용 (lazy loading)
- 무거운 연산은 `compute()` 또는 Isolate로 분리한다

### 이미지 최적화
- `Image.asset()`에 `cacheWidth`/`cacheHeight` 지정
- SVG 이미지는 `flutter_svg` 사용
- 네트워크 이미지는 `CachedNetworkImage` 사용

### 빌드 최적화
- Tree shaking을 위해 사용하지 않는 import 제거
- `--release` 빌드에서 성능 테스트
- `DevTools` Performance 탭으로 jank 확인 (60 FPS 유지)

## 생명주기 관리

- `StatefulWidget`에서 리소스는 `initState()`에서 할당, `dispose()`에서 해제
- `Stream` subscription, `AnimationController`, `TextEditingController`는 반드시 dispose
- `WidgetsBindingObserver`로 앱 생명주기 감지

```dart
@override
void dispose() {
  _controller.dispose();
  _subscription.cancel();
  super.dispose();
}
```

## 에러 UI 처리

- 모든 비동기 상태에 loading, error, data 3가지 상태를 처리한다
- `AsyncValue.when()`으로 패턴 매칭한다
- 사용자 친화적 에러 메시지를 제공한다 (기술적 에러 메시지 노출 금지)
- SnackBar 또는 전용 에러 Widget으로 에러를 표시한다

## 접근성 (Accessibility)

- `Semantics` Widget으로 스크린 리더 지원
- 터치 타겟 최소 48x48dp 보장
- 충분한 색상 대비 (WCAG 2.1 기준)
- `ExcludeSemantics`로 장식용 요소 제외

## 국제화 (i18n)

- 하드코딩 문자열 대신 `l10n` 사용
- `intl` 패키지로 날짜/숫자 포맷팅
- RTL 레이아웃 고려

## 플랫폼 적응

- `Platform.isIOS`, `Platform.isAndroid`로 플랫폼별 분기
- iOS에서는 Cupertino 위젯 고려
- Android Material You 다이나믹 컬러 지원
- Platform Channel은 추상화 계층을 두고 사용
