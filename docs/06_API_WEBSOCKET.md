# API 및 WebSocket 계약 초안
## 1. HTTP
| 메서드 | 경로 | 목적 |
|---|---|---|
| POST | /api/auth/signup | 로컬 회원가입 |
| POST | /api/auth/login | 로컬 로그인 |
| GET | /oauth2/authorization/google | Google OAuth2 로그인 시작 |
| GET | /oauth2/authorization/kakao | Kakao OAuth2 로그인 시작 |
| POST | /api/auth/refresh | 인증 토큰 재발급 |
| POST | /api/auth/logout | 로그아웃 |
| GET | /api/users/me | 내 프로필 조회 |
| POST | /api/rooms | 방 생성 |
| GET | /api/rooms | 공개 방 조회 |
| POST | /api/rooms/{roomId}/join | 참가 |
| POST | /api/rooms/{roomId}/leave | 퇴장 |
| POST | /api/rooms/{roomId}/start | 방장 시작 |
| GET | /api/rooms/{roomId}/snapshot | 재연결 상태 복원 |
| GET | /api/users/me/stats | 전적(2차) |
| GET | /actuator/health/readiness | 배포 readiness |

## 2. STOMP
- 연결: `/ws` (JWT 인증, Origin 검증).
- 클라이언트 발행: `/app/rooms/{roomId}/pass` body `{commandId, expectedVersion}`.
- 서버 브로드캐스트: `/topic/rooms/{roomId}/events`.
- 개인 결과: `/user/queue/commands`.
- 상태 복원: HTTP snapshot 또는 `/app/rooms/{roomId}/sync`.
- 서버 이벤트 예: `PLAYER_JOINED`, `GAME_STARTED`, `BOMB_PASSED`, `BOMB_EXPLODED`, `PLAYER_ELIMINATED`, `GAME_FINISHED`.

## 3. 에러 계약
```json
{"code":"NOT_BOMB_OWNER","message":"현재 폭탄 소유자가 아닙니다","commandId":"uuid","stateVersion":12}
```
주요 코드: `ROOM_FULL`, `GAME_ALREADY_STARTED`, `NOT_BOMB_OWNER`, `PASS_COOLDOWN`, `BOMB_ALREADY_EXPLODED`, `STALE_VERSION`, `DUPLICATE_COMMAND`, `NOT_PARTICIPANT`.

## 4. 재연결
- 연결이 끊기면 지수 백오프로 재시도.
- 재연결 후 snapshot 조회 → stateVersion 비교 → 누락 이벤트 보완 또는 최신 스냅샷 덮어쓰기.
- 중복 이벤트는 eventId/version 기준으로 무시.
- 서버 배포 시 기존 WebSocket 연결이 유지된다는 보장은 없음. graceful shutdown, reconnect, state restore가 필요.

## 5. 분산 서버 고려
- Spring simple broker는 다른 JVM의 세션을 알지 못함. 각 서버는 Redis Stream/릴레이에서 이벤트를 수신해 자신의 로컬 세션으로 브로드캐스트.
- Redis Pub/Sub만 사용하면 구독 중단 시 이벤트 유실 가능. 스냅샷 버전 복원으로 보완.
