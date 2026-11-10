# RabbitMQ / Kafka 메시징 설계
## 1. 역할 구분
- RabbitMQ: 실행해야 하는 작업 — `game.result.persist`, `reward.grant`, `notification.send`.
- Kafka: 발생한 사실 — `bomb.passed`, `bomb.exploded`, `player.eliminated`, `game.finished`.
- Redis: 즉각적인 소유권 판정과 게임 상태. 브로커는 Redis 판정을 대체하지 않음.

## 2. RabbitMQ 토폴로지
- Exchange: `game.tasks` (direct, durable).
- Queue: `game.result.persist.q`, `game.reward.grant.q` (durable, quorum queue는 리소스 비용 고려).
- Retry: 별도 retry queue + TTL + DLX 또는 애플리케이션 지수 백오프. 무한 재큐잉 금지.
- DLX: `game.dlx`, Queue: `game.dead.q`.
- Publisher confirms + mandatory routing/return 처리; 메시지 persistent.
- Consumer manual ACK: DB commit 성공 후 ACK, 실패 시 NACK/재시도.
- 멱등 키: `gameId + taskType + resultVersion`.

## 3. Kafka 토폴로지
- Topic `game.events.v1`, key=`roomId`, value=JSON 이벤트 envelope.
- 같은 roomId는 동일 파티션으로 보내 순서를 보존. 서로 다른 방 간 전역 순서는 없음.
- Consumer Group `game-analytics-v1`: 전달 수, 평균 생존시간, 탈락 패턴.
- Consumer Group `game-archive-v1`: 장기 이벤트 보관(선택).
- 단일 노드 학습 환경: replication.factor=1, 장애 허용 안 됨. 프로덕션 수준 고가용성 아님.
- Consumer는 처리 완료 후 offset commit. 중복 소비 대비 eventId dedupe.

## 4. 공통 이벤트 스키마 예시
```json
{
  "eventId": "01J...",
  "schemaVersion": 1,
  "eventType": "BOMB_PASSED",
  "roomId": 123,
  "round": 2,
  "stateVersion": 17,
  "occurredAt": "2026-11-11T13:00:00Z",
  "actorId": 7,
  "targetId": 11
}
```
개인정보/인증 토큰은 이벤트 payload에 포함하지 않음.

## 5. 실패 시나리오
| 상황 | 기대 동작 |
|---|---|
| RabbitMQ 발행 실패 | durable relay/outbox에서 재발행 |
| Consumer 처리 중 종료 | 미ACK 재전달, DB 멱등 처리 |
| 보상 DB 실패 | 제한적 재시도 후 DLQ, 운영자 재처리 |
| Kafka 일시 중단 | Redis Stream에 보관된 이벤트 재발행 |
| Kafka 중복 이벤트 | eventId로 중복 집계 방지 |
| Kafka 순서 혼동 | roomId key, version 검사, 파티션 내 순서 활용 |

## 6. 구현 순서
1. RabbitMQ 없이 동기 결과 저장으로 MVP 검증.
2. RabbitMQ 작업 큐와 멱등 Worker, DLQ 추가.
3. Redis Stream 이벤트 로그와 Kafka 발행 릴레이 추가.
4. 별도 Consumer Group과 재처리/lag 테스트.

## 관리형 저장소 연계
- RabbitMQ/Kafka는 Oracle VM에 실제 배포한다. 결과 Worker는 Supabase PostgreSQL에 TLS로 연결하며 `ON CONFLICT` 기반 멱등 처리한다.
- Kafka 릴레이의 원천 이벤트는 Upstash Redis Stream이다. 선택 플랜에서 Stream 명령·소비 패턴을 검증하고 무료 요청 한도/RTT를 계측한다.
