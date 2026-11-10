# Upstash Redis 자료구조 및 원자적 게임 상태

## 1. 선택 및 검증
- 관리형 **Upstash Redis**를 게임 상태의 권위 있는 저장소로 사용한다. 자체 Redis 컨테이너/AOF 설정은 운영 범위에서 제외.
- **연결 방식 결정 필요:** Spring Boot에서 TLS Redis 프로토콜 연결을 우선 검토하고, 선택한 Upstash 플랜의 TCP/TLS·REST·Pub/Sub·Streams·EVAL 지원 여부를 실제 계정에서 검증한다. REST 방식에서는 요청당 호출 오버헤드 및 트랜잭션/스크립트 제한 확인.
- 서버와 Upstash 리전 간 RTT를 측정한다. 폭탄 전달은 지연 민감하므로 위치·요청 한도·과금 한도를 검증해야 함.

## 2. 키 설계
| 키 패턴 | 타입 | 목적 | TTL |
|---|---|---|---|
| `game:{roomId}:state` | HASH | status, ownerId, round, version, explodeAtMs, lastPassAtMs | 종료 후 24h |
| `game:{roomId}:alive` | SET | 생존자 ID | 종료 후 24h |
| `game:{roomId}:players` | SET | 참가자 ID | 종료 후 24h |
| `game:{roomId}:commands` | HASH | commandId→처리 결과/버전 | 종료 후 24h |
| `game:{roomId}:events` | STREAM | 상태 이벤트, Kafka/RabbitMQ 릴레이 입력 | 소비 후 정리 |
| `game:{roomId}:presence` | ZSET | userId→마지막 heartbeat 시간 | 종료 후 1h |

`{roomId}`는 동일 방 관련 키를 한 해시 슬롯에 두기 위한 Redis Cluster 해시태그 관례. 실제 키 예: `game:{123}:state`.

## 3. 폭탄 전달 원자 처리
1. `commandId` 재전송 여부 검사.
2. Redis 서버 시간으로 RUNNING, 폭발 시각 미도달, version, ownerId 검사.
3. 대상 생존·본인 제외·쿨타임 검증. **대상 직접 선택/무작위 모드 여부는 미확정 정책**.
4. 소유자 변경, 버전 증가, 마지막 전달 시각 갱신.
5. 같은 원자적 실행 안에서 이벤트를 Stream에 추가하고 결과 반환.
6. Lua/EVAL 지원이 실제 연결 방식에서 확인되면 Lua로 구현. 미지원이면 동일 수준의 원자성 보장이 가능한 다른 설계로 재검토; 분리된 GET/SET만으로 대체 금지.

## 4. 폭발 및 연결 끊김
- 만료 판정과 탈락 처리를 원자적으로 확정. 중복 타이머 워커가 동시에 실행해도 단 한 번 처리.
- 클라이언트 연결 상태는 소유권과 별도 관리. **재접속 유예/자동 전달/탈락 정책은 미확정**이며 악용 방지 테스트 후 결정.
- WebSocket 다중 인스턴스는 이벤트 릴레이 + 스냅샷 재조회로 동기화. Pub/Sub은 유실 가능하므로 단독 진실 원천으로 사용하지 않음.

## 5. 관리형 Redis 장애·비용
- Upstash는 관리형이므로 직접 `redis.conf`, AOF, maxmemory-policy를 설정할 수 있다고 가정하지 않는다.
- 무료 요금제의 데이터 크기, 명령/요청량, 처리량, 보존 및 eviction 정책을 확인하고 지표를 수집.
- Redis 장애·상태 유실 시 경기 취소 또는 복구 정책을 문서화. Kafka 이벤트가 있다고 자동 복구되지는 않음.
- Stream 무한 증가 방지: 소비자 커서 추적 후 XTRIM/삭제. 메시지 릴레이 중복 처리는 eventId로 멱등화.
