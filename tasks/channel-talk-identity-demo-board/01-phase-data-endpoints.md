# Phase 1: Data Endpoints

## 공통 진행 지시사항

- 이 phase가 끝나면 반드시 커밋한다.
- 커밋 전에 자동 테스트와 필요한 수동 확인을 수행하고, 확인한 명령이나 화면을 기록한다.
- phase 종료 시 회귀 위험과 개선사항을 리뷰한다.
- 완료한 내용, 검증 결과, 남은 위험, 개선사항은 `completion-log.md`에 업데이트한다.
- 구현 중 배운 내용 때문에 남은 작업 순서나 범위가 달라지면 이후 phase 문서도 함께 업데이트한다.
- 계획과 실제 구현이 다르면 실제 구현을 기준으로 문서를 고친다.
- 텍스트 설명을 늘려 문제를 덮지 않는다. 가능한 한 플로우차트, payload, DB 레코드, 상태값으로 보여준다.
- 외부 API 실패를 성공처럼 보이게 만들지 않는다. 실패 상태와 원인을 화면에 그대로 남긴다.
- DB trigger는 사용하지 않는다. 상태 갱신은 controller, service, job처럼 코드에서 보이는 경로로 처리한다.
- 기존 작업자의 변경 사항을 되돌리지 않는다. unrelated dirty worktree는 그대로 두고 필요한 파일만 좁게 수정한다.

## 목표

데모 보드가 표시할 identity, payload, DB 레코드, delivery 상태를 하나의 presenter와 JSON endpoint로 제공한다.

## 구현 범위

- `ChannelIdentityDemoPayload` 또는 유사한 presenter 추가
- HTML page endpoint 추가
- JSON status endpoint 추가
- demo purchase action 추가
- run delivery action 추가
- controller/model 테스트 추가

## 데이터 항목

- current user: `id`, `uuid`, `member_id`, `name`, `email_address`, `created_at`
- mapping: `member_id`, `channel_user_id`, `synced_at`, `last_error`
- latest order
- latest purchase event
- latest delivery: `status`, `attempts`, `channel_event_id`, `last_error`, `sent_at`
- User API request preview
- S2S Event API request preview
- S2S JSON payload preview

## 검증 방법

- `bin/rails test`
- JSON endpoint가 필요한 key를 반환하는지 controller test로 확인
- demo purchase action이 실제 `Order`, `Event`, `ChannelEventDelivery`를 만드는지 확인
- run delivery action이 delivery job을 실행하거나 실패 상태를 기록하는지 확인

## 완료 조건

- UI 없이도 JSON response만으로 식별자 매핑과 S2S payload를 설명할 수 있다.
- 외부 API 키가 없을 때 실패가 `last_error`로 남는다.
- `completion-log.md`에 완료 내용, 검증, 회귀 위험, 개선사항을 기록한다.
