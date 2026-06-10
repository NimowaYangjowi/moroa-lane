# Project Brief: ChannelTalk Identity Demo Board

## 면접 시나리오

Acme Corp은 자체 서비스 회원이 채널톡 채팅을 시작하면 이름, 이메일, 가입일 같은 고객 정보를 상담창에서 보고 싶어한다. 이후 상담 이력과 서버 이벤트도 고객 단위로 조회하고 싶어한다.

이 데모 보드는 그 흐름을 말로 길게 설명하지 않고 실제 값으로 보여준다.

## 화면에서 답해야 하는 질문

- `memberId`는 Acme가 안정적으로 관리하는 고객 키다.
- `userId`는 채널톡 User API 응답으로 얻는 채널톡 내부 User 키다.
- S2S 이벤트 전송은 `memberId`가 아니라 채널톡 `userId` path를 사용한다.
- 내부 DB는 두 식별자를 `channel_user_mappings`로 분리해 저장한다.
- 외부 API 실패는 `channel_event_deliveries`의 `status`, `attempts`, `last_error`에 남는다.

## 화면 정보 구조

### 상단

- 현재 로그인 고객
- `memberId`
- 채널톡 `userId`
- latest delivery status

### 중앙

- 플로우차트
  - Acme user
  - SDK boot identity
  - User API lookup
  - Mapping table
  - S2S Purchase payload
  - Delivery status
- 선택된 단계 없이도 전체 흐름이 보이는 고정 보드로 만든다.

### 오른쪽

- User API request
- S2S Event API request
- 실제 S2S JSON payload

### 하단

- 실제 DB 레코드
  - `users`
  - `orders`
  - `events`
  - `channel_user_mappings`
  - `channel_event_deliveries`

## 액션

- `Create demo purchase`: 로그인 사용자의 장바구니가 비어 있으면 대표 상품을 담고, 실제 주문 생성 flow로 `purchase` 이벤트와 delivery를 만든다.
- `Run delivery now`: 최신 pending/failed delivery를 즉시 job으로 실행해 상태 변화를 보여준다.
- `Refresh`: JSON endpoint를 다시 읽는다.

## 시각 기준

- 긴 설명 문단을 넣지 않는다.
- 표와 JSON, 짧은 라벨, 상태 칩으로 설명한다.
- 카드 중첩을 피하고, page section은 full-width band 또는 unframed layout으로 둔다.
- 버튼은 명령 역할이 분명해야 한다.
- 모바일에서는 1열로 접히되 JSON과 DB 값이 잘리지 않게 가로 스크롤을 허용한다.

## 제외 범위

- 실제 채널톡 상담창 자동 조작
- 채널톡 대시보드 iframe 또는 스크래핑
- 실제 결제 연동
- 관리자용 retry queue 전체 운영 도구
- 복잡한 그래프 라이브러리 도입
