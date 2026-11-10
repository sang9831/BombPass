# 테스트 계획 및 검증 지표
## 1. 단위/통합
- Lua: 정상 전달, 비소유자, 자기 자신, 쿨타임, 폭발 경계, 동일 commandId, stale version.
- 게임 상태 머신: 대기/시작/폭발/종료, 2명·30명 경계.
- DB: 결과 중복 INSERT, 보상 ledger UNIQUE, 재시도 시 전적 중복 증가 없음.
- RabbitMQ: ACK 전 종료, 재전달, retry, DLQ, publisher confirm.
- Kafka: 동일 roomId 파티션 순서, Consumer 재시작, offset replay, eventId dedupe.
- WebSocket: 서로 다른 Spring 인스턴스 접속자의 이벤트 수신 및 재연결 복원.

## 2. 동시성 실험
| 시나리오 | 부하 | 합격 기준 |
|---|---|---|
| 같은 소유자 동시 전달 100건 | 100 병렬 | 같은 stateVersion에서 성공 1건 |
| 폭발 시각 근처 전달 | 반복 경계 테스트 | 만료 이후 성공 0건 |
| 동일 commandId 재전송 | 100회 | 상태 변경 1회 |
| 두 서버에서 동시 명령 | 서버 A/B 혼합 | 소유자 중복 0건 |
| 결과 메시지 중복 소비 | 10회 | DB 결과/보상 1회 |

## 3. 부하 테스트
- 시나리오 A: 50→100→300 WebSocket 동시 접속 점진 증가.
- 시나리오 B: 폭탄 전달 명령 집중(동일 roomId, 여러 roomId 분리).
- 시나리오 C: 서버 1개 vs 같은 VM의 2개 컨테이너 vs 분리 VM(동일 총 리소스) 비교.
- 지표: WS 연결 성공률, RPS/명령 처리량, p50/p95/p99, 오류율, CPU, RSS, GC pause, Redis latency, RabbitMQ queue depth, Kafka consumer lag.
- 부하 발생기는 가능하면 별도 로컬 PC/VM에서 실행해 서버 자원 경쟁을 피함.
- t3 계열처럼 버스터블 VM은 CPU 크레딧 등 변수를 기록. Oracle 환경에서도 CPU 제한과 자원 사용량을 함께 기록.
- 모든 측정은 동일 조건 3회 이상 반복하고 평균과 분산 보고.

## 4. 장애 주입
- Spring A kill → B 연결 사용자 정상 진행, A 사용자 재연결.
- Upstash 연결 장애/타임아웃 모의 → 상태 보존/유실 여부 및 복구 정책 검증.
- RabbitMQ kill → 발행 재시도, 결과 영속화 누락 방지.
- Kafka kill → 이벤트 적체, 복구 후 재발행.
- DB kill → Worker retry, 게임 진행과 결과 저장 분리.
- Blue/Green 전환 중 게임 진행 → 재연결/상태 버전 확인.

## 5. 증거 자료
테스트 환경(인스턴스/CPU/RAM/네트워크), 테스트 스크립트, 지표 그래프, 실패 로그, 개선 전후 비교표, 한계 명시.

## 외부 관리형 서비스 및 인증 테스트
- Supabase PostgreSQL: 풀 고갈, 네트워크 지연, 프로젝트 유휴 중지, `ON CONFLICT` 멱등성.
- Upstash Redis: EVAL/Streams 지원, 명령/요청 한도, RTT, 네트워크 장애, 타임아웃 후 중복 명령 재시도.
- 로컬·Google·Kakao: 회원가입, OAuth state, 토큰 만료/재발급, 중복 계정 연결 및 탈취 방어.
- RabbitMQ와 Kafka가 실제 Oracle VM에서 동시 가동되는 상태로 메모리/CPU/디스크 및 부하 테스트 수행.
