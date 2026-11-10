# 💣 BOMB PASS — VS Code Starter

React 19 + TypeScript + Vite / Java 21 + Spring Boot 4.1.2 / Supabase PostgreSQL / Upstash Redis / RabbitMQ / Kafka.

## 0. 준비물
- VS Code, JDK 21, Node.js 22+, Docker Desktop, **Gradle 9.x** (wrapper 추가 전 임시 필요)
- Supabase PostgreSQL JDBC URL/계정, Upstash **Redis TCP/TLS** 엔드포인트/비밀번호

## 1. VS Code 열기
`File > Open Folder`에서 이 프로젝트 루트를 열고 추천 확장을 설치합니다.

## 2. 프론트 실행
```bash
cd frontend
npm install
npm run dev
```
http://localhost:5173

## 3. 로컬 RabbitMQ/Kafka 실행
```bash
docker compose -f infra/compose.yaml up -d
```
RabbitMQ 관리 UI: http://localhost:15672 (로컬 전용 guest/guest)

Supabase/Upstash 연결 전 로컬 대체 서비스가 필요하면:
```bash
docker compose -f infra/compose.yaml --profile local-db --profile local-redis up -d
```

## 4. 백엔드 실행
`backend/.env.example`을 참고하여 환경변수를 설정하세요. **`.env` 파일은 Spring Boot가 자동으로 읽지 않습니다.** VS Code 실행 구성이나 터미널에서 환경변수를 주입해야 합니다.

Gradle wrapper가 아직 포함되지 않았으므로 설치된 Gradle 9.x에서 다음을 실행해 생성합니다:
```bash
cd backend
gradle wrapper --gradle-version 9.2.1
./gradlew bootRun
```
Windows PowerShell에서는 `gradlew.bat bootRun`을 사용합니다.

기본 연결값은 로컬 PostgreSQL/Redis/RabbitMQ/Kafka입니다. Supabase/Upstash 연결 시 DATABASE_*, REDIS_* 변수를 지정합니다.

- Backend health: http://localhost:8080/api/health
- Swagger UI: http://localhost:8080/swagger-ui/index.html

## 중요: 초기 골격 범위
- 현재는 **실행용 스캐폴드**이며 로그인, JWT 발급, OAuth2, 폭탄 전달, 메시지 발행/소비, 실시간 다중 서버 동기화는 **미구현**입니다.
- WebSocket `/ws`는 개발용 simple broker입니다. 멀티 인스턴스 운영에는 별도 이벤트 전달 구조가 필요합니다.
- JWT는 Spring Security Nimbus 기반으로 구현 예정이며 비밀키와 토큰 저장 정책은 추후 적용합니다.
- 실제 운영에서는 TLS, 외부 서비스 접속 보호, RabbitMQ/Kafka 인증, Blue/Green 연결 드레이닝을 추가해야 합니다.
- Boot 4.1.2 / springdoc 3.2.0 의존성 조합은 **이 환경에서 빌드 검증되지 않았습니다.** 첫 빌드에서 호환성을 확인하고 조정하세요.
- `docs/`에는 이전 기획 문서 v1.2를 동봉했습니다. 문서의 Vue/Spring Boot 3 표기가 남아 있다면 현재 README의 React 19 / Spring Boot 4.1.2가 우선합니다.
