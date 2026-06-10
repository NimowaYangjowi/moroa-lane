# Completion Log

이 문서는 phase가 끝날 때마다 업데이트한다. 단순히 완료 여부만 적지 말고, 무엇을 검증했고 어떤 회귀 위험이 남았는지 같이 기록한다.

## Phase 0: Planning Documents

완료일: 2026-06-10
커밋: 162ca13

### 완료한 것

- `tasks/channel-talk-s2s-purchase/` 폴더를 만들었다.
- S2S purchase 연동의 목표, 데이터 흐름, 식별자 매핑, phase 계획을 문서화했다.
- 각 phase 문서 최상단에 커밋, 검증, 회귀 리뷰, 완료 로그, 남은 계획 업데이트 지시사항을 넣었다.
- 리뷰 중 중복 전송 위험을 줄이기 위해 delivery `processing` 상태와 원자적 상태 전환 기준을 계획에 보강했다.

### 검증한 것

- 새 작업 폴더의 문서 목록을 확인했다.
- 각 phase 문서 최상단에 공통 진행 지시사항이 들어갔는지 확인했다.
- 계획 문서를 재검토해 외부 API 실패, 중복 전송, 매핑 실패가 조용히 숨겨지지 않는지 확인했다.

### 회귀 위험

- 아직 구현 전 계획이므로 실제 checkout 흐름과 job 구조는 구현 중 조정될 수 있다.

### 개선사항

- Phase 1에서 실제 Rails 모델명과 migration 결과에 맞춰 이후 phase 문서를 업데이트한다.

### 다음 phase 계획 변경

- 변경 없음

## Phase 1: Data Model

완료일: 2026-06-10
커밋: f5c4686

### 완료한 것

- `Event::NAMES`에 `purchase`를 추가했다.
- `ChannelUserMapping` 모델과 `channel_user_mappings` 테이블을 추가했다.
- `ChannelEventDelivery` 모델과 `channel_event_deliveries` 테이블을 추가했다.
- delivery 상태를 `pending`, `processing`, `sent`, `failed`로 제한했다.
- 내부 이벤트 한 건당 delivery를 하나만 만들 수 있도록 `event_id` unique 제약을 추가했다.
- `User`, `Event`에 채널톡 매핑과 delivery association을 연결했다.
- 모델 테스트를 추가해 `purchase` 이벤트, mapping validation, delivery 상태와 중복 방지를 확인했다.

### 검증한 것

- `bin/rails db:migrate`
- `bin/rails test test/models/event_test.rb test/models/channel_user_mapping_test.rb test/models/channel_event_delivery_test.rb`
- `bin/rails test`

### 회귀 위험

- `channel_user_id`가 없는 mapping을 허용했다. Phase 3에서 채널톡 User 조회 실패와 매핑 재시도 정책을 명확히 구현해야 한다.
- 오래 남은 `processing` delivery를 어떻게 회수할지는 아직 구현하지 않았다. Phase 3에서 bounded retry와 상태 전환 기준을 구현해야 한다.

### 개선사항

- Phase 3에서 `pending -> processing` 전환을 원자적으로 처리하는 메서드를 모델이나 job에 둔다.
- Phase 3에서 채널톡 API 응답의 event ID 필드명을 실제 응답에 맞춰 저장한다.

### 다음 phase 계획 변경

- 변경 없음
