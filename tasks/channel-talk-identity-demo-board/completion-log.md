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
