---
paths:
  - "db/**"
  - "drizzle/**"
  - "drizzle.config.ts"
  - "docker-compose.yml"
---

# DB Migration Protocol

DB 스키마/데이터에 영향을 줄 수 있는 작업 전 **필수** 절차. `db:push`, `migrate`, `drop`, schema 파일 수정, docker-compose 볼륨/이미지 변경 등 모두 포함.

## 1. 사전 점검 (변경 전 반드시 수행)

다음을 확인하지 않고 destructive 명령을 실행하지 말 것.

1. **컨테이너/볼륨 상태**
   - `docker volume ls | grep <project>` — 사용 중/유휴 볼륨 모두 확인
   - `docker inspect <container> --format '{{range .Mounts}}{{.Name}} -> {{.Destination}}{{"\n"}}{{end}}'` — 실제 마운트된 볼륨
   - 후보 볼륨이 여러 개면 임시 컨테이너로 각각 마운트해 row count 확인 (어느 볼륨에 데이터가 있는지)
2. **현재 DB 상태**
   - `\dt`로 테이블 목록
   - 핵심 테이블 row count
3. **연결 설정**
   - `.env.local`의 `DATABASE_URL`과 실제 컨테이너 포트가 일치하는지

## 2. 사전 백업 (destructive 작업 시 필수)

```bash
docker exec <db_container> pg_dump -U <user> -d <db> -Fc -f /tmp/backup.dump
docker cp <db_container>:/tmp/backup.dump ./db-backup-$(date +%Y%m%d-%H%M%S).dump
```

백업 파일 크기 확인 후에만 다음 단계 진행. 백업 0바이트면 중단.

## 3. 변경 계획을 사용자에게 먼저 보고

다음 4가지를 한 화면에 정리하여 보고하고, 사용자 승인 없이 실행하지 말 것.

- 현재 상태 (어떤 볼륨/DB/스키마, row count)
- 변경 후 상태 (생성/삭제/변경되는 테이블·컬럼)
- 영향받는 데이터 (행 수, 영향 범위)
- 롤백 방법 (백업 파일 경로, 복원 명령)

## 4. drizzle-kit 사용 주의

- `drizzle.config.ts`는 `.env.local`을 자동 로드하지 않음. 인라인으로 환경변수를 넘길 것:
  ```bash
  DATABASE_URL="postgresql://..." npx drizzle-kit push
  ```
- `drizzle-kit push`는 column drop 등 destructive 변경을 인터랙티브 prompt로 묻기도 함. 비대화형 환경에서 자동 yes 금지.

## 5. docker-compose 볼륨 함정

- compose 프로젝트명은 디렉토리명을 따름 → **폴더명을 바꾸면 새 빈 볼륨이 생성**되어 기존 데이터가 "사라진 것처럼" 보임
- 영구 고정: `docker-compose.yml`에 외부 볼륨 명시
  ```yaml
  volumes:
    pgdata:
      external: true
      name: <고정-볼륨-이름>
  ```

## ⚠️ 금지 사항

- 사전 점검 없이 `db:push`/`migrate`/`drop` 실행
- 백업 없이 `DROP DATABASE`, `TRUNCATE`, schema reset
- 사용자 동의 없이 destructive 마이그레이션 실행
- "빈 DB로 보이니까 그냥 push"라고 판단 — 다른 볼륨에 데이터가 있을 수 있음
