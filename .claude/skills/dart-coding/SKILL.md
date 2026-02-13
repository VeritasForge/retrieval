---
name: dart-coding
description: Dart idiomatic coding conventions and best practices. Ensures all Dart code follows Effective Dart guidelines with readable, efficient, and modern patterns.
user-invocable: false
---

# Dart Idiomatic Coding

Dart 코드를 작성할 때 반드시 아래 원칙을 따른다. 모든 원칙은 Effective Dart 공식 가이드에 기반한다.

## 핵심 철학

1. **Be consistent**: 코드가 달라 보이면, 의미적으로도 달라야 한다
2. **Be brief**: 간결하게 작성한다

## 네이밍 컨벤션

- 'UpperCamelCase': 클래스, enum, typedef, type parameter, extension
- 'lowerCamelCase': 변수, 함수, 메서드, 파라미터, named constant
- 'snake_case': 파일명, 패키지명, 디렉토리명
- '_' 접두사: 라이브러리 수준 private member
- 약어도 CamelCase 규칙을 따른다 ('HttpRequest', 아니라 'HTTPRequest')

## 타입 시스템

### Null Safety
- 모든 타입은 기본적으로 non-nullable이다
- nullable이 필요한 경우에만 '?' 사용: 'String? name'
- '!' 연산자 사용을 최소화한다 (null이 아님을 확신할 때만)
- late 변수는 초기화가 보장될 때만 사용한다

### 타입 추론 vs 명시적 타입
- 로컬 변수: 타입 추론 사용 ('var', 'final')
- Public API: 명시적 타입 선언
- 컬렉션 리터럴: 타입 추론 활용 ('final items = <String>[]' 보다 'final items = ['a']')

## 변수 선언

### final과 const
- 재할당하지 않는 변수는 반드시 'final' 사용
- 컴파일 타임 상수는 'const' 사용
- Widget에서 'const' constructor 적극 활용 (성능 + hot-reload 이점)

~~~dart
// Good
final name = 'Flutter';
const maxRetries = 3;
const widget = SizedBox(height: 8);

// Bad
var name = 'Flutter'; // 재할당 안 하면 final 사용
~~~

## 컬렉션

- 불변 컬렉션 선호: 'List.unmodifiable()', 'Map.unmodifiable()'
- 빈 컬렉션 리터럴 사용: '[]', '{}', '<Type>[]'
- 'whereType<T>()' 사용하여 타입 필터링
- spread 연산자 ('...') 활용

~~~dart
// Good
final combined = [...list1, ...list2];
final filtered = items.whereType<String>().toList();

// Bad
final combined = List<String>.from(list1)..addAll(list2);
~~~

## 함수와 메서드

- 짧은 함수는 arrow syntax ('=>') 사용
- named parameter 적극 활용 (boolean flag 대신)
- callback에서 미사용 파라미터는 '_' 사용 (Dart 3.7+ wildcard)
- 함수형 프로그래밍 메서드 활용: 'map', 'where', 'fold', 'expand'

~~~dart
// Good
void onTap(String value, _) => print(value);
final names = users.map((u) => u.name).toList();

// Bad
void onTap(String value, dynamic unused) => print(value);
~~~

## Cascade 연산자 ('..')

같은 객체에 대한 연속 조작 시 cascade 사용:

~~~dart
// Good
final button = TextButton()
  ..text = 'Click'
  ..onPressed = handleClick
  ..style = buttonStyle;

// Bad
final button = TextButton();
button.text = 'Click';
button.onPressed = handleClick;
button.style = buttonStyle;
~~~

## Dart 3+ 모던 패턴

### Pattern Matching & Destructuring
~~~dart
// Record destructuring
final (name, age) = getUserInfo();

// Switch expression
final label = switch (status) {
  Status.active => 'Active',
  Status.inactive => 'Inactive',
  Status.pending => 'Pending',
};

// If-case
if (json case {'name': String name, 'age': int age}) {
  print('$name is $age years old');
}
~~~

### Sealed Classes
~~~dart
sealed class Result<T> {}
final class Success<T> extends Result<T> {
  final T value;
  Success(this.value);
}
final class Failure<T> extends Result<T> {
  final Exception error;
  Failure(this.error);
}

// Exhaustive pattern matching
final message = switch (result) {
  Success(:final value) => 'Got: $value',
  Failure(:final error) => 'Error: $error',
};
~~~

### Extension Methods
~~~dart
extension StringX on String {
  String get capitalize => '${this[0].toUpperCase()}${substring(1)}';
  bool get isEmail => RegExp(r'^[\w-.]+@[\w-]+\.\w+$').hasMatch(this);
}
~~~

### Extension Types (Dart 3.3+)
~~~dart
extension type UserId(String value) {
  factory UserId.fromInt(int id) => UserId(id.toString());
}
~~~

## 에러 처리

- 구체적인 예외 타입 정의 및 사용
- 'catch'에서 가능한 구체적 타입으로 캐치
- 'rethrow' 사용 (stack trace 보존)
- 'Error'는 프로그래밍 오류, 'Exception'은 런타임 오류

~~~dart
// Good
try {
  await fetchData();
} on NetworkException catch (e) {
  handleNetworkError(e);
} on FormatException catch (e) {
  handleFormatError(e);
}

// Bad
try {
  await fetchData();
} catch (e) {
  print(e); // 너무 광범위
}
~~~

## 비동기 프로그래밍

- 'async'/'await' 선호 ('.then()' 체인 대신)
- 'Stream' 적절히 활용하고 반드시 cancel/dispose
- 'Future.wait()'로 병렬 실행
- 'Completer'는 꼭 필요할 때만 사용

~~~dart
// Good
final results = await Future.wait([
  fetchUsers(),
  fetchPosts(),
]);

// Bad
fetchUsers().then((users) {
  fetchPosts().then((posts) {
    // nested callback
  });
});
~~~

## 문서화

- Public API에는 '///' doc comment 작성
- 첫 줄은 한 문장 요약
- 파라미터 설명이 필요하면 문장 내에서 자연스럽게
- 구현이 명확한 getter/setter는 문서 생략 가능
- 코드 내 '//' 주석은 "왜(why)"를 설명할 때만 사용

## Import 순서

1. 'dart:' 라이브러리
2. 'package:' 라이브러리
3. relative import
4. 각 그룹 사이에 빈 줄

~~~dart
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';

import '../models/user.dart';
import 'utils.dart';
~~~

## 린팅

- 'analysis_options.yaml'에서 strict 린트 규칙 활성화
- 'avoid_print' 규칙 사용 (로깅은 logger 패키지 사용)
- 'prefer_final_locals', 'prefer_const_constructors' 활성화
- 'dart format'으로 자동 포맷팅 적용
