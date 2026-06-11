# Completion Log

이 문서는 phase가 끝날 때마다 업데이트한다. 단순히 완료 여부만 적지 말고, 무엇을 검증했고 어떤 회귀 위험이 남았는지 같이 기록한다.

## Phase 0: Planning Documents

완료일: 2026-06-11
커밋: d822b78

### 완료한 것

- `tasks/channel-talk-identity-demo-board/` 폴더를 만들었다.
- 면접용 identity demo board의 목적, 화면 정보 구조, phase 계획을 문서화했다.
- 각 phase 문서 최상단에 커밋, 검증, 회귀 리뷰, 완료 로그, 남은 계획 업데이트 지시사항을 넣었다.
- 긴 설명 대신 플로우차트, payload, DB record, live delivery 상태를 중심으로 구현하도록 기준을 세웠다.

### 검증한 것

- phase 문서가 0-3 단계로 나뉘어 있는지 확인했다.
- 기존 `channel-talk-s2s-purchase` 계획과 역할이 겹치지 않게 demo board만 별도 범위로 분리했다.

### 회귀 위험

- 아직 구현 전 계획이므로 실제 화면 구성은 구현 중 조정될 수 있다.

### 개선사항

- Phase 1에서 실제 presenter key와 endpoint 이름이 정해지면 Phase 2 문서에 반영한다.

### 다음 phase 계획 변경

- 변경 없음

## Phase 1: Data Endpoints

완료일: 2026-06-11
커밋: 13339df

### 완료한 것

- `PurchaseOrder` 서비스를 추가해 일반 주문 흐름과 데모 구매 흐름이 같은 주문 생성 로직을 쓰게 했다.
- `ChannelIdentityDemoSnapshot`을 추가해 identity, User API request, S2S Event API request, payload, DB record를 JSON으로 만들었다.
- `/debug/channel/identity-flow` shell page를 추가했다.
- `/debug/channel/identity-flow/status` JSON endpoint를 추가했다.
- `/debug/channel/identity-flow/purchase` demo purchase action을 추가했다.
- `/debug/channel/identity-flow/deliver` delivery run action을 추가했다.
- presenter, controller, purchase service 테스트를 추가했다.
- 실제 endpoint 이름과 snapshot key를 Phase 2 문서에 반영했다.

### 검증한 것

- `bin/rails test test/controllers/channel_identity_demo_controller_test.rb test/services/purchase_order_test.rb test/models/channel_identity_demo_snapshot_test.rb test/controllers/orders_controller_test.rb`
- `bin/rails test`

### 회귀 위험

- demo purchase action은 장바구니가 비어 있으면 대표 상품을 자동으로 담는다. 면접 데모 편의 기능이므로 실제 commerce checkout로 오해되지 않게 Phase 2 화면에서 액션 라벨을 명확히 해야 한다.
- delivery run action은 failed delivery를 attempts 상한 전까지만 pending으로 되돌린다. 상한 이후에는 실패 상태를 그대로 보여준다.

### 개선사항

- Phase 2에서 JSON shell을 실제 플로우차트, payload viewer, DB record board로 교체한다.
- Phase 2에서 자동 polling 간격을 짧게 잡되 과도한 요청이 되지 않게 2초 이상으로 둔다.

### 다음 phase 계획 변경

- Phase 2는 `ChannelIdentityDemoSnapshot`의 `identity`, `flow`, `requests`, `payload`, `records` key를 기준으로 구현한다.

## Phase 2: Visual Board

완료일: 2026-06-11
커밋: f10a0ae

### 완료한 것

- `/debug/channel/identity-flow` shell을 면접용 visual board로 교체했다.
- 상단 identity summary에 Acme user, `memberId`, 채널톡 `userId`, delivery 상태를 표시했다.
- 중앙에 플로우차트형 stage board를 추가했다.
- User API request와 S2S Event API request를 별도 request viewer로 표시했다.
- S2S `Purchase` payload를 JSON block으로 표시했다.
- `users`, `orders`, `events`, `channel_user_mappings`, `channel_event_deliveries` 최신 레코드를 DB table 형태로 표시했다.
- `Create demo purchase`, `Run delivery now`, `Refresh` 버튼을 fetch action으로 연결했다.
- 2초 polling으로 status endpoint를 다시 읽고 화면을 갱신하게 했다.
- 모바일에서 1열로 접히고 JSON/DB 값이 스크롤되도록 CSS를 추가했다.

### 검증한 것

- `bin/rails test test/controllers/channel_identity_demo_controller_test.rb`
- `bin/rails test`

### 회귀 위험

- 브라우저에서 실제 클릭과 polling 동작은 Phase 3에서 확인해야 한다.
- inline JavaScript로 구현했으므로 화면이 커지면 별도 JS 모듈로 분리할 수 있다.

### 개선사항

- Phase 3에서 desktop/mobile 브라우저 화면을 확인하고 겹침이나 가독성 문제가 있으면 조정한다.
- Phase 3에서 README에 데모 보드 URL과 발표 순서를 추가한다.

### 다음 phase 계획 변경

- 변경 없음

## Phase 3: Verification And Docs

완료일: 2026-06-11
커밋: 612d80a

### 완료한 것

- README에 `/debug/channel/identity-flow` 데모 보드 URL과 발표 순서를 추가했다.
- README의 interview talking points에 `memberId`, 채널톡 `userId`, User API lookup, S2S Event API request, payload, DB record 설명을 추가했다.
- `ChannelIdentityDemoController`와 `OrdersController`에서 `PurchaseOrder` 서비스를 전역 상수로 명시해 컨트롤러 네임스페이스 상수 탐색 문제를 줄였다.
- 새 Rails 서버에서 실제 인증 세션과 CSRF token을 사용해 `status`, `purchase`, `deliver` endpoint를 검증했다.

### 검증한 것

- `bin/rails test test/controllers/channel_identity_demo_controller_test.rb test/controllers/orders_controller_test.rb test/services/purchase_order_test.rb`
- `bin/rails test`
- `PIDFILE=tmp/pids/server-3002.pid bin/rails server -p 3002`
- 인증된 HTTP 검증:
  - `GET /debug/channel/identity-flow`: `200`
  - `GET /debug/channel/identity-flow/status`: `200`
  - `POST /debug/channel/identity-flow/purchase`: `201`
  - `POST /debug/channel/identity-flow/deliver`: `200`
  - status payload에서 `memberId`와 `GET /open/v5/users/@{memberId}` 경로 확인
  - purchase payload에서 `Purchase` 이벤트와 `pending` delivery 확인
  - delivery run 후 `CHANNELTALK_ACCESS_KEY is required` 실패 원인이 DB record payload에 남는 것 확인

### 회귀 위험

- 이 세션에서 headless browser 도구와 Playwright가 제공되지 않아 desktop/mobile 렌더링 스크린샷 검증은 수행하지 못했다.
- 실제 ChannelTalk Open API credential이 없으므로 `sent` 상태까지는 검증하지 못했고, missing credential failure 경로를 확인했다.
- 기존 3001 개발 서버는 `app/services` 디렉터리가 추가되기 전 떠 있던 프로세스라 새 서비스를 autoload하지 못했다. 데모 전에는 Rails 서버를 재시작해야 한다.

### 개선사항

- 발표 전 실제 브라우저에서 `/debug/channel/identity-flow`를 열어 desktop/mobile 폭에서 flowchart와 DB table overflow를 한 번 더 확인한다.
- 실제 채널톡 Open API key를 넣을 수 있으면 `Run delivery now`가 `sent` 상태로 바뀌는 경로까지 별도로 캡처한다.

### 다음 phase 계획 변경

- 남은 phase 없음

## Post-phase Fix: Live Counters

완료일: 2026-06-11
커밋: 5315129

### 완료한 것

- `Create demo purchase` 클릭 결과가 화면에서 바로 보이도록 `Purchase events`, `Orders`, `Deliveries` 실시간 카운터를 추가했다.
- snapshot JSON에 `metrics.purchaseEvents`, `metrics.orders`, `metrics.deliveries`를 추가했다.
- 카운터가 실제 사용자 기준 DB count와 맞고, purchase action 후 1씩 증가하는 테스트를 추가했다.

### 검증한 것

- `bin/rails test test/models/channel_identity_demo_snapshot_test.rb test/controllers/channel_identity_demo_controller_test.rb`
- `bin/rails test`
- 인증된 HTTP 검증:
  - purchase 전 `purchaseEvents=1`, `orders=2`, `deliveries=1`
  - purchase 후 `purchaseEvents=2`, `orders=3`, `deliveries=2`
- `browse` 검증:
  - 로그인, 로그아웃, 회원가입
  - 상품 목록, 상품 상세, 장바구니 추가
  - 장바구니 수량 변경과 제거
  - 주문 생성 후 마이페이지 이동
  - `/debug/channel` payload 표시
  - `/debug/channel/identity-flow` 카운터 증가, `Purchase` payload 표시, delivery 실패 원인 표시
  - `Guide`, `About` nav 링크
  - desktop/mobile screenshot 및 모바일 가로 overflow 없음

### 회귀 위험

- status polling마다 count query 3개가 추가된다. 이 화면은 면접용 debug board라 비용 영향은 작지만, 운영 대시보드로 확장한다면 집계 캐시나 페이지네이션 기준으로 다시 설계해야 한다.

### 개선사항

- 실제 발표 전에는 채널톡 credential을 넣은 상태에서 `sent` delivery 경로까지 한 번 더 확인한다.

### 다음 phase 계획 변경

- 남은 phase 없음

## 후속 작업 포인터

이 보드의 UI 리디자인(identity bridge, 연결형 레일, 단계↔아티팩트 연결, not-configured 상태 프레이밍, 변화 펄스, DB 위계화)은 [tasks/channel-talk-identity-board-redesign](../channel-talk-identity-board-redesign)에서 진행했다.
