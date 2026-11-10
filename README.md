# 💣 BOMB PASS

**BOMB PASS**는 2~30인이 실시간으로 즐기는 웹 기반 멀티플레이 폭탄 돌리기 게임입니다.  
서버 권위 모델과 Redis 원자 연산을 통해 폭탄의 단일 소유권을 엄격하게 보장하며, WebSocket(STOMP), RabbitMQ, Kafka를 결합하여 안정적인 실시간 상태 동기화 및 대규모 이벤트 스트리밍을 제공합니다.

---

## 🛠 기술 스택

| 영역 | 기술 |
|---|---|
| **Frontend** | React 19, TypeScript, Vite |
| **Backend** | Java 21, Spring Boot 4.1.2, Gradle |
| **Database & Cache** | Supabase PostgreSQL, Upstash Redis |
| **Messaging & Streaming** | RabbitMQ (실시간 메시지 브로커), Apache Kafka (이벤트 발행/통계 집계) |
| **Infrastructure** | Docker Compose |

---

## 📁 디렉토리 구조

```
BOMB_PASS/
├── backend/          # Java / Spring Boot 백엔드 애플리케이션
├── frontend/         # React / Vite 프론트엔드 웹 애플리케이션
├── infra/            # 로컬 개발용 인프라 구성 (Docker Compose: RabbitMQ, Kafka, DB 등)
├── docs/             # 프로젝트 기획, 아키텍처, ERD, API 명세 및 협업 컨벤션
│   ├── collaboration/ # GitHub 이슈 및 PR 컨벤션
│   └── *.md          # 제품 요구사항(PRD), 아키텍처, DB 설계 등 상세 기술 문서
└── .github/          # GitHub Issue 및 PR 템플릿
```

---

## 🚀 로컬 개발 환경 실행 방법

### 1. 사전 준비물
- **Node.js** 22+ & npm
- **JDK** 21
- **Docker Desktop**
- **Gradle** 9.x (최초 wrapper 생성용)

---

### 2. 로컬 메시지 브로커 / 인프라 구동
RabbitMQ와 Kafka를 Docker Compose로 실행합니다.
```bash
docker compose -f infra/compose.yaml up -d
```
- **RabbitMQ Management UI**: http://localhost:15672 (기본 계정: `guest` / `guest`)

> **로컬 PostgreSQL 및 Redis도 함께 구동하려면:**
> ```bash
> docker compose -f infra/compose.yaml --profile local-db --profile local-redis up -d
> ```

---

### 3. 프론트엔드 (Frontend) 실행
```bash
cd frontend
npm install
npm run dev
```
- 브라우저 접속: http://localhost:5173

---

### 4. 백엔드 (Backend) 실행
1. **환경 변수 확인**: `backend/.env.example`을 참고하여 실행 환경변수(DB/Redis/RabbitMQ/Kafka 접속 정보)를 설정합니다. (`.env` 파일은 Spring Boot가 직접 읽지 않으므로 터미널 또는 IDE 실행 구성에 주입 필요)
2. **Gradle Wrapper 생성 및 실행**:
```bash
cd backend
# Gradle wrapper 생성 (최초 1회)
gradle wrapper --gradle-version 9.2.1

# 애플리케이션 실행
./gradlew bootRun
# Windows PowerShell:
# .\gradlew.bat bootRun
```
- **Backend Health Check**: http://localhost:8080/api/health
- **Swagger UI**: http://localhost:8080/swagger-ui/index.html

---

## 📌 현재 개발 상태 (초기 스캐폴드)
- 현재 저장소는 개발을 위한 **초기 실행용 스캐폴드** 단계입니다.
- 로그인, OAuth2/JWT 인증, 실시간 폭탄 전달 판정 및 다중 서버 동기화는 순차적으로 구현될 예정입니다.
- 상세 요구사항 및 설계 내용은 [`docs/`](./docs) 디렉토리의 문서를 참고하세요.
