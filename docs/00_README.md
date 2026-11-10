# BOMB PASS — 기획 문서 인덱스
버전 1.2 · 2026-11-11 · 상태: 구현 전 설계 초안

## 목적
2~30인 웹 실시간 폭탄 돌리기 게임. **Supabase PostgreSQL**로 영구 데이터를 관리하고 **Upstash Redis**에서 게임 상태와 원자적 소유권 판정을 처리한다. Oracle Cloud ARM VM에는 Spring Boot, RabbitMQ, Kafka를 실제 배포하여 분산 서버·로드밸런싱·Blue/Green을 실험한다.

## 확정 결정
- 게스트 로그인 없음. **로컬 이메일/비밀번호, Google OAuth2, Kakao OAuth2** 지원.
- RDBMS: **Supabase PostgreSQL** (Oracle VM에서 MySQL 컨테이너 운영하지 않음).
- Redis: **Upstash Redis** (Oracle VM에서 Redis 컨테이너 운영하지 않음).
- RabbitMQ와 Kafka: **Oracle Cloud에서 실제 운영**, 로컬 전용으로 축소하지 않음.
- 전달 대상 선택 및 연결 끊김 정책은 유사 게임 조사 기반 후보안이며 **미확정**. 플레이 테스트 후 확정.
- 무료 티어 한도, 리전·지연, Upstash 명령/스크립트 지원, Supabase 연결 수와 절전 정책은 배포 전 실측/확인.

## 문서 목록
- 01_PRODUCT_REQUIREMENTS: 요구사항·게임 규칙·인증
- 02_ARCHITECTURE: 데이터/이벤트 흐름과 장애 경계
- 03_ERD_DATABASE: PostgreSQL ERD, OAuth 계정 연결, 제약·인덱스
- 04_REDIS_DESIGN: Upstash 키/자료구조·원자적 명령·제약
- 05_MESSAGING: RabbitMQ/Kafka 토폴로지·멱등성
- 06_API_WEBSOCKET: 인증 REST·STOMP·재접속
- 07_INFRA_DEPLOYMENT: Oracle VM + Supabase + Upstash + 브로커 배포
- 08_TEST_PLAN: 정합성·부하·외부 서비스 장애 테스트
- 09_ROADMAP: 8주 개발 일정
- 10_OPERATIONS_SECURITY: 보안·비용·운영 런북

## 공통 가정
- 방당 2~30명, MVP 플레이 검증은 2~10명부터 확장.
- 폭발 시각은 서버가 결정한 10~20초 랜덤 타이머. 최종 판정은 Redis 원자 연산 순서.
- 전달 쿨타임 1초(조정 가능). 폭탄 전달·폭발은 서버 권위 판정.
- **정책 후보:** 대상 직접 선택을 기본으로 하고 무작위 모드는 추후 옵션; 재접속 유예 10초. 모두 확정 전 플레이 테스트 필요.
- 수치와 일정은 목표치이며 실측 결과가 아님.
