# 8주 개발 로드맵 (1인 기준, 유동적)
| 주차 | 목표 | 산출물/완료 조건 |
|---|---|---|
| 1주 | 요구사항·게임 규칙·화면·ERD | PRD 확정, UI 와이어프레임, API 초안 |
| 2주 | Spring Boot/Supabase PostgreSQL/로컬·소셜 인증/방 관리 | 방 생성·참가·시작 API, 통합 테스트 |
| 3주 | Upstash Redis 게임 엔진 | Lua 전달/폭발/멱등, 100병렬 경쟁 테스트 |
| 4주 | WebSocket 및 프론트 MVP | 2~10명 실제 플레이, 재연결 상태 복원 |
| 5주 | RabbitMQ + 결과 DB | Worker ACK/retry/DLQ, 중복 보상 0건 |
| 6주 | Kafka 서버 운영 + 이벤트 분석 | Stream→Kafka 릴레이, 재처리/lag 실험 |
| 7주 | Oracle Kafka·RabbitMQ 배포 / LB | 다중 인스턴스 상태 공유, 무료 VM 배포 |
| 8주 | Blue/Green·부하·장애 테스트 | 롤백 시연, 측정 리포트, README/데모 |

## 우선순위
- P0: 실제 플레이 가능한 게임 + Redis 소유권 정합성 + WebSocket 재연결.
- P1: RabbitMQ, Supabase PostgreSQL 결과 영속화, CI/CD, Nginx 다중 인스턴스.
- P2: Kafka 서버 배포, 이벤트 분석, 클라우드 VM 분리, Blue/Green, 랭킹.
- P3: 특수 아이템, 스킨, 관전자, 매치메이킹.

## Definition of Done
- 기능: 자동화 테스트 + 예외 처리 + 로깅 + README 사용법.
- 인프라: 재현 가능한 Docker Compose, 비밀 정보 저장소 제외.
- 성능: 테스트 조건과 지표 재현 가능.
- 운영: 장애 시 복구 방법과 알려진 한계 문서화.
