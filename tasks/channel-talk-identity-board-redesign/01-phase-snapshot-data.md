# Phase 1: Snapshot Data & State Semantics

## 공통 진행 지시사항

- 이 phase가 끝나면 반드시 커밋한다. 커밋은 phase 단위로 하나씩 넣는다.
- 커밋 전에 자동 테스트와 필요한 수동 확인(브라우저 desktop/mobile 포함)을 수행하고, 확인한 명령이나 화면을 기록한다.
- phase 종료 시 회귀 위험과 개선사항을 리뷰한다.
- 완료한 내용, 검증 결과, 남은 회귀 위험, 개선사항은 `completion-log.md`에 업데이트한다.
- 구현 중 배운 내용 때문에 남은 작업 순서나 범위가 달라지면, 이후 phase 문서도 함께 업데이트한 뒤 다음 phase로 넘어간다.
- 계획과 실제 구현이 다르면 실제 구현을 기준으로 문서를 고친다.
- 텍스트 설명을 늘려 문제를 덮지 않는다. 의미는 레이아웃, 위치, 색 역할, 상태 칩, 모션으로 보여준다.
- 외부 API 실패를 성공처럼 보이게 만들지 않는다. 실패와 미설정(credentials not set)을 구분해 둘 다 화면에 정직하게 남긴다.
- 색은 의미 역할에만 쓴다: input(`memberId`), output(`userId`), 서버 신뢰 payload, success, pending, failure, not-configured.
- DB trigger는 사용하지 않는다. 상태 갱신은 controller, service, job처럼 코드에서 보이는 경로로 처리한다.
- live update가 추가 비용을 만들지 않게 polling 간격과 query 수를 기존 수준으로 유지한다(2초 이상, count query 추가 금지).
- 기존 작업자의 변경 사항을 되돌리지 않는다. unrelated dirty worktree는 그대로 두고 필요한 파일만 좁게 수정한다.

## 목표

이후 phase의 시각 표현(색 역할, 변환 카드, 상태 프레이밍)이 안정적으로 그릴 수 있도록, 표현에 필요한 의미 데이터를 `ChannelIdentityDemoSnapshot` JSON에 먼저 추가한다. 이 phase는 데이터/의미 계층만 다루고 화면은 바꾸지 않는다.

## 구현 범위

[app/models/channel_identity_demo_snapshot.rb](../../app/models/channel_identity_demo_snapshot.rb)에 아래를 추가한다.

- **flow 단계별 key 역할**: `flow` 각 항목에 `keyRole`을 추가한다.
  - `acme_user`, `member_id`, `user_api` → `"input"` (memberId를 쓰는 단계)
  - `mapping`, `s2s_event`, `delivery` → `"output"` (userId를 쓰는 단계)
  - 이후 Phase 2 가로 레일의 input/output 색 보더가 이 값을 기준으로 칠해진다.
- **자격증명 / delivery 상태 분류**: `identity`(또는 신규 `delivery` 블록)에 표현용 분류를 추가한다.
  - `credentialsConfigured` (boolean): `CHANNELTALK_ACCESS_KEY`와 `CHANNELTALK_ACCESS_SECRET`가 모두 있으면 true.
  - `deliveryState` (string): 표현용 분류값. 다음 규칙으로 만든다.
    - delivery 레코드가 없으면 `"none"`.
    - `credentialsConfigured`가 false이고 delivery가 실패/대기면 `"not_configured"`.
    - 그 외에는 실제 `status`(`pending`/`processing`/`sent`/`failed`)를 그대로 쓴다.
  - 원본 `deliveryStatus`(실제 DB status)와 `last_error`는 그대로 유지한다. **실제 실패를 숨기지 않는다.** `not_configured`는 "credentials가 없어서 아직 못 보냄"을 의미하고, credentials가 있는데 실패하면 계속 `failed`로 보여준다.
- **bridge 표현 값**: `identity`에 변환 카드가 바로 쓸 수 있는 라벨 데이터를 추가한다.
  - `memberId`, `channelUserId`는 이미 있음. 추가로 `channelUserId`가 없을 때 표시할 의미를 명확히 하기 위해 `mappingStatus`(이미 있음: `not_created`/`waiting_for_user_api`/`synced`)를 그대로 활용한다. 신규 필드가 꼭 필요하면 최소로만 추가한다.

`serverCredentials.accessKey`/`accessSecret`의 기존 `"configured"`/`"missing"` 문자열은 유지하되, 화면 상태 분류는 새 `credentialsConfigured`/`deliveryState`를 기준으로 한다.

## 검증 방법

- [test/models/channel_identity_demo_snapshot_test.rb](../../test/models/channel_identity_demo_snapshot_test.rb)에 케이스 추가:
  - 각 flow 단계의 `keyRole`이 기대값(input/output)과 맞는다.
  - credentials 미설정 + 실패 delivery일 때 `deliveryState == "not_configured"`이고 원본 `deliveryStatus`는 그대로 `failed`다.
  - credentials 설정 + 실패 delivery일 때 `deliveryState == "failed"`다 (실패를 숨기지 않음).
  - delivery 없을 때 `deliveryState == "none"`.
- `bin/rails test test/models/channel_identity_demo_snapshot_test.rb`
- `bin/rails test`

## 완료 조건

- snapshot JSON에 `flow[].keyRole`, `credentialsConfigured`, `deliveryState`가 들어간다.
- 실제 delivery 실패는 여전히 `failed`/`last_error`로 남는다.
- 화면(ERB/CSS)은 이 phase에서 바뀌지 않는다.
- `completion-log.md`에 완료 내용, 검증, 회귀 위험, 개선사항을 기록한다.
- 실제 필드명이 계획과 달라지면 Phase 2~3 문서의 참조를 실제 key로 업데이트한다.
