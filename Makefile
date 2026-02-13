.PHONY: get build run test analyze clean setup check sim-list sim-boot sim-run sim-kill run-macos run-chrome

## 의존성 설치
get:
	flutter pub get

## Hive 어댑터 코드 생성
build:
	flutter pub run build_runner build --delete-conflicting-outputs

## 앱 실행
run:
	flutter run

## 테스트 실행
test:
	flutter test

## 정적 분석
analyze:
	flutter analyze

## 빌드 캐시 정리
clean:
	flutter clean
	rm -rf .dart_tool build

## 초기 셋업 (의존성 + 코드 생성)
setup: get build

## 테스트 + 분석 한번에
check: analyze test

# ---------- Simulator ----------

## 시뮬레이터 기기 목록 조회
sim-list:
	xcrun simctl list devices available

## 시뮬레이터 부팅 (기본: iPhone 16 Pro, DEVICE 변수로 변경 가능)
DEVICE ?= iPhone 16 Pro
sim-boot:
	open -a Simulator
	xcrun simctl boot "$(DEVICE)" 2>/dev/null || true

## 시뮬레이터 부팅 + 앱 실행
sim-run: sim-boot
	flutter run -d "$(DEVICE)"

## 시뮬레이터 종료
sim-kill:
	xcrun simctl shutdown all

# ---------- 기타 플랫폼 ----------

## macOS 데스크톱으로 실행
run-macos:
	flutter run -d macos

## Chrome 웹으로 실행
run-chrome:
	flutter run -d chrome
