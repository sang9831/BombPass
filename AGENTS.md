# AGENTS.md — BOMB PASS

이 문서는 이 저장소에서 작업하는 코딩 에이전트를 위한 공통 지침이다. 답변과 문서, 커밋 메시지는 한국어로 작성한다.

## 프로젝트 개요

- 실시간 멀티플레이 폭탄 돌리기 게임의 모노레포다.
- `backend/`: Java 21, Spring Boot 4.1.2, Gradle.
- `frontend/`: React 19, TypeScript, Vite.
- 데이터·메시징: Supabase PostgreSQL, Upstash Redis, RabbitMQ, Kafka.
- 현재는 실행용 스캐폴드다. README에 구현 예정이라고 적힌 기능을 이미 구현된 것으로 가정하지 않는다.

## 작업 전 확인

- 먼저 관련 요구사항과 설계 문서를 읽고, 문서와 구현이 다르면 임의로 한쪽을 바꾸지 말고 사용자에게 확인한다.
- 제품 요구사항: `docs/01_PRODUCT_REQUIREMENTS.md`
- 아키텍처와 데이터 흐름: `docs/02_ARCHITECTURE.md`
- 스키마: `docs/03_ERD_DATABASE.md`
- Redis 처리: `docs/04_REDIS_DESIGN.md`
- 메시징: `docs/05_MESSAGING.md`
- API 및 WebSocket: `docs/06_API_WEBSOCKET.md`
- 배포·보안·테스트: `docs/07_INFRA_DEPLOYMENT.md`, `docs/08_TEST_PLAN.md`, `docs/10_OPERATIONS_SECURITY.md`
- 실행 방법과 현재 구현 범위는 `README.md`를 따른다.

## 구현 원칙

- 기존 구조와 의존성을 우선 사용하고, 요청 범위를 넘는 추상화나 기능을 추가하지 않는다.
- 게임 상태와 폭탄 소유권 판정은 문서가 정한 Redis 원자 연산 및 서버 권위 흐름을 따른다. 클라이언트 시계나 별도 캐시를 판정 근거로 사용하지 않는다.
- DB 기록과 메시지 처리는 문서에 정의된 멱등성, 재시도, 중복 방지 규칙을 유지한다.
- 이미 커밋된 Flyway 마이그레이션은 수정하지 않고 새 버전 마이그레이션을 추가한다.
- 인증 정보와 비밀값을 코드, 로그, 문서, 커밋에 넣지 않는다. 기존 `.env.example`만 참고한다.
- 미확정 게임 정책은 확정된 요구사항처럼 구현하지 않는다. 구현에 꼭 필요하면 먼저 확인한다.

## 실행 및 검증

- 프론트엔드: `cd frontend`, `npm install`, `npm run dev`; 검증은 `npm run build` 또는 `npm run typecheck`.
- 백엔드: `cd backend`, 설치된 Gradle로 wrapper를 생성한 뒤 README에 적힌 `./gradlew bootRun` (Windows: `gradlew.bat bootRun`)을 사용한다. 테스트는 `./gradlew test` (Windows: `gradlew.bat test`).
- 브로커 로컬 실행: `docker compose -f infra/compose.yaml up -d`.
- 변경한 영역에 맞는 검증을 수행하고, 실행하지 못한 항목과 이유를 결과에 적는다. CI 체크가 없거나 경로 조건으로 건너뛴 경우 이를 테스트 통과로 간주하지 않는다.
- 테스트나 빌드는 사용자가 요청했거나 변경 확인에 필요한 경우에만 실행한다.

## Git 및 공유 작업

- 코드 변경은 작업마다 별도 브랜치를 만든 뒤 그 브랜치에서 진행한다. 기준 브랜치는 저장소 규칙이나 사용자의 지정을 따르고, 정해져 있지 않으면 임의로 추측하지 말고 확인한다.
- `main` 및 기준 브랜치에 직접 코드 변경을 커밋하거나 푸시하지 않는다. 변경은 Pull Request를 통해서만 병합한다.
- 단, 원격 저장소가 완전히 비어 있을 때 사용자가 최초 게시를 명시적으로 요청하면 초기 `main` 푸시는 한 번 허용한다. 초기화 이후에는 PR 규칙을 적용한다.
- 이슈 추적은 Jira가 아닌 GitHub Issues를 사용한다. 기존 이슈가 있으면 해당 번호를 브랜치와 Pull Request에 연결하고, 이슈 번호나 저장소 브랜치 규칙을 임의로 만들거나 추측하지 않는다.
- 이슈 본문과 제목은 `docs/collaboration/ISSUE_CONVENTION.md`, PR 본문과 제목은 `docs/collaboration/PR_CONVENTION.md`를 따른다. GitHub 등록 화면에서 이 규칙을 쓸 수 있도록 `.github/ISSUE_TEMPLATE/` 및 `.github/pull_request_template.md` 템플릿을 유지한다.
- 브랜치·커밋 규칙이 저장소에 따로 있으면 작업 전에 확인해 따른다.
- 커밋, 푸시, Pull Request 생성은 사용자가 명시적으로 요청한 경우에만 수행한다.
- 작업 전후 기존 변경사항을 보존하고, 요청하지 않은 파일은 수정하지 않는다.
- 최종 보고는 한국어로 변경 내용과 검증 결과, 미실행 항목을 간단히 정리한다.
