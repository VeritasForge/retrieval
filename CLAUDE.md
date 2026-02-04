# Retrieval - 복습 관리 앱

## 프로젝트 개요

에빙하우스 망각곡선 기반 간격 반복 학습(Spaced Repetition)을 활용한 복습 관리 앱

## 기술 스택

- **Flutter** - 크로스 플랫폼 프레임워크
- **Riverpod** - 상태 관리 (flutter_riverpod, riverpod_annotation)
- **Hive** - 로컬 데이터 저장 (hive, hive_flutter)
- **fl_chart** - 도넛 차트
- **uuid** - 고유 ID 생성
- **equatable** - 값 객체 동등성 비교
- **intl** - 국제화/날짜 포맷팅

## 아키텍처

Clean Architecture 적용 - `lib/features/[feature]/` 하위에 `domain/`, `data/`, `presentation/` 레이어 분리

### Features

- **category** - 카테고리 관리
- **review** - 복습 스케줄 관리
- **statistics** - 통계/차트
- **study_item** - 학습 항목 관리

### Core

- `lib/core/constants/` - 상수 (복습 주기 등)
- `lib/core/exceptions/` - 예외 처리
- `lib/core/utils/` - 유틸리티

## 복습 주기 옵션

- **1-3-7**: 1일 후, 3일 후, 7일 후
- **1-3-7-14**: 1일 후, 3일 후, 7일 후, 14일 후
- **1-4-7-14**: 1일 후, 4일 후, 7일 후, 14일 후
- **2-3-5-7**: 2일 후, 3일 후, 5일 후, 7일 후
