# Completion Log

이 문서는 phase가 끝날 때마다 업데이트한다. 단순히 완료 여부만 적지 말고, 무엇을 검증했고 어떤 회귀 위험이 남았는지 같이 기록한다.

## Phase 0: Planning Documents

완료일: 2026-06-11
커밋: 9ee55ea

### 완료한 것

- `tasks/channel-talk-identity-board-redesign/` 폴더를 만들었다.
- `/debug/channel/identity-flow` 보드 리디자인의 목적, 현행 문제, 새 정보 구조, 시각 토큰 기준을 문서화했다.
- 구현을 5개 phase(snapshot data → bridge/rail → artifact/state → motion/hierarchy → verification/docs)로 분리했다.
- 각 phase 문서 최상단에 공통 진행 지시사항(phase별 커밋, 테스트/수동 검증, 회귀 리뷰, completion-log 업데이트, 남은 phase 문서 업데이트, honest failure, 색 역할 제한, polling 비용 유지, 좁은 수정 범위)을 동일하게 넣었다.
- `identity-board-redesign` 작업 브랜치를 만들었다(기존 main 보호).

### 검증한 것

- 실제 보드를 인증 세션으로 띄워 desktop(1440)/mobile(390) 현행 상태를 캡처하고 문제를 확인했다(flowchart 비방향성, 끊긴 영역, 빨강 FAILED 첫인상, 카드 위계 뭉침, 색 미사용, 변화 피드백 없음).
- 기존 `channel-talk-identity-demo-board` 문서 컨벤션(README/00-brief/phase/review-template/completion-log)에 맞춰 폴더 구조를 정렬했다.

### 회귀 위험

- 아직 구현 전 계획이므로 실제 색 토큰 값과 레일 레이아웃은 구현 중 조정될 수 있다.
- Phase 1에서 snapshot 필드명이 확정되면 Phase 2~4 문서의 참조 key를 실제 값으로 맞춰야 한다.

### 개선사항

- Phase 2에서 input/output primitive 색 hex를 확정하면 00-project-brief.md의 시각 토큰 표를 실제 값으로 업데이트한다.

### 다음 phase 계획 변경

- 변경 없음

## Phase 1: Snapshot Data & State Semantics

완료일: 2026-06-11
커밋: (phase 1 commit)

### 완료한 것

- `ChannelIdentityDemoSnapshot`의 `flow` 각 단계에 `keyRole`을 추가했다(`acme_user`/`member_id`/`user_api` = input, `mapping`/`s2s_event`/`delivery` = output). Phase 2 레일의 input/output 색 보더 기준이 된다.
- `identity`에 `credentialsConfigured`(boolean)와 `deliveryState`(표현용 분류)를 추가했다.
- `deliveryState` 규칙: delivery 없음 → `none`, credentials 미설정 + 실패/대기 → `not_configured`, 그 외 실제 status 그대로(`pending`/`processing`/`sent`/`failed`).
- 원본 `deliveryStatus`와 `last_error`는 그대로 유지해 실제 실패를 숨기지 않는다.
- 화면(ERB/CSS)은 변경하지 않았다(데이터/의미 계층만).

### 검증한 것

- `bin/rails test test/models/channel_identity_demo_snapshot_test.rb` (5 runs, 22 assertions)
- `bin/rails test` (65 runs, 380 assertions, 0 failures)
- 라이브 status endpoint(인증 세션, 3001)에서 확인: `deliveryStatus=failed`(honest)인데 `deliveryState=not_configured`, `credentialsConfigured=false`, 6단계 `keyRole`이 input/output로 기대대로 출력됨.
- 신규 테스트: keyRole 매핑, credentials 미설정 시 not_configured + 원본 failed 유지, credentials 설정 시 failed 유지, delivery 없음 시 none.

### 회귀 위험

- `credentials_configured?`는 `CHANNELTALK_ACCESS_KEY`/`SECRET` 둘 다 present일 때만 true다. 한쪽만 설정된 부분 구성은 not-configured로 분류된다(현 의도와 일치).
- 테스트의 `with_env`가 전역 ENV를 변경하지만, Rails parallelize는 프로세스 분리라 워커 간 간섭 없음.

### 개선사항

- Phase 2에서 bridge/rail이 `keyRole`과 `mappingStatus`/`channelUserId`를 그대로 소비하면 되므로 추가 snapshot 필드는 불필요할 전망.

### 다음 phase 계획 변경

- 변경 없음. 확정된 snapshot key: `flow[].keyRole`, `identity.credentialsConfigured`, `identity.deliveryState`. Phase 2~3은 이 key를 그대로 참조한다.
