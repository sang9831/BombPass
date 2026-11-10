# 운영·보안·위험 관리
## 1. 모니터링
- Spring Actuator/Micrometer: 요청 수, 5xx, p95, JVM heap, GC, thread pool.
- Redis: used_memory, evictions, command latency, connected_clients, Stream backlog.
- RabbitMQ: ready/unacked, redelivery, DLQ 건수.
- Kafka: consumer lag, publish failure, disk usage.
- Nginx: upstream 상태, 502/504, WebSocket 연결 수.
- 게임: 동시 방 수, 전달 성공/실패, 중복 차단, 상태 버전 불일치, 재연결 성공률.
- 무료 VM 리소스 부족 시 Prometheus/Grafana는 로컬에서 실행하거나 최소한의 메트릭만 저장.

## 2. 보안
- 로컬 비밀번호는 Argon2id/BCrypt 해시, Google/Kakao OAuth2 state 검증, JWT 서명/만료/재발급 및 계정 연결 정책 정의.
- WebSocket CONNECT/메시지에서 인증 및 방 참가 권한 검증.
- Origin/CORS 제한, 전송 빈도 제한, 비정상 명령 차단.
- 폭탄 소유권/시간은 클라이언트 값 신뢰 금지.
- 게임방 코드는 추측 방지 및 입장 시도 제한.
- DB와 브로커 관리자 UI는 공용 인터넷에서 접근 금지.
- 로그에 토큰/개인정보 기록 금지.

## 3. 운영 런북
- RabbitMQ DLQ 적체: 실패 원인 확인 → 멱등성 확인 → 선택 재처리.
- Kafka lag 증가: 소비자 상태/파티션/CPU 확인 → 처리량 제한 조정.
- Redis 상태 유실: 경기 복원 가능 여부 판단 → 불가하면 방 종료 및 사용자 안내.
- WebSocket 끊김: 자동 재연결 → snapshot 동기화 → 불일치 시 최신 상태 우선.
- 배포 실패: 신규 연결 이전 버전으로 전환, 이전 버전 호환성 확인.

## 4. 주요 위험
| 위험 | 영향 | 완화 |
|---|---|---|
| 무료 VM 용량 부족 | 컨테이너 OOM | 단계적 도입, 메모리 제한, Kafka/RabbitMQ 메모리 제한 및 배치 최적화 |
| 단일 Redis 장애 | 진행 게임 유실 | Upstash 내구성 정책 확인, 상태 복원/경기 취소 테스트 |
| 브로커 이중 쓰기 | 이벤트 누락 | Redis Stream/Outbox 릴레이 |
| 다중 서버 WS 브로드캐스트 | 일부 사용자 미수신 | 서버 간 relay + snapshot 복원 |
| Blue/Green 시 WS 단절 | 플레이 중 끊김 | 드레이닝·재연결·상태 복원 |
| 무료 클라우드 과금 | 예상치 못한 비용 | 한도/알림/생성 리소스 정기 확인 |

## 5. 결정 필요 항목
- 로컬·Google·Kakao 계정 연결 정책
- 폭탄 대상 자동 선택 vs 사용자 지정
- 연결 끊김 시 탈락 정책
- 시즌 보상/점수 계산식
- Kafka·RabbitMQ 클라우드 운영 자원 배치
- ARM VM 2대 실제 생성 가능 여부와 최종 무료 리소스 한도
