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
커밋: 0bcc7ab

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

## Phase 2: Identity Bridge & Connected Rail

완료일: 2026-06-11
커밋: ed502ac

### 완료한 것

- 상단 `identity-summary`(4칸)를 `memberId → userId` 변환 카드(identity bridge)로 교체했다. 좌측 memberId(input), 화살표 위 `User API lookup` + `GET /open/v5/users/@{memberId}`, 우측 userId(output) + `mappingStatus` 칩 구조.
- input/output 의미 색을 `.identity-demo-board`의 CSS custom property(`--identity-input-*`, `--identity-output-*`)로 정의해 bridge와 rail이 같은 색 언어를 공유하게 했다. input=teal 계열, output=amber 계열.
- 6단계 flowchart를 3열×2행 그리드에서 화살표(`→`)로 연결된 가로 레일로 교체했다. `flow[].keyRole`에 따라 input 단계(01-03)는 teal, output 단계(04-06)는 amber 보더/배경.
- 레일을 2열 grid에서 빼내 full-width 밴드로 올려, 6단계가 좌→우 한 줄로 읽히게 했다(`identity-board-grid` 래퍼 제거, flow-board/inspector를 board 직속 full-width 섹션으로).
- 모바일에서 bridge는 1열, 레일은 세로열로 접히고 화살표가 `↓`로 바뀌도록 media query를 추가했다.
- inline JS: `renderFlow`를 화살표 구분자 + keyRole data 속성 마크업으로 수정, `mappingStatus`가 bridge·inspector 두 곳에 있으므로 `setStateChipAll`로 모두 갱신, 제거된 `acmeUserId`/`deliveryStatus` summary 필드 갱신 코드 정리.

### 검증한 것

- `bin/rails test` (65 runs, 380 assertions, 0 failures) — 뷰 렌더 회귀 없음.
- 라이브 status endpoint `200`.
- `browse` desktop(1440): bridge의 input(teal)/output(amber) 색 대비, 화살표 위 GET 경로, 레일의 좌→우 화살표 연결과 키 전환 색(03 input→04 output) 확인. 스크린샷 `/tmp/p2-desktop-fold.png`, `/tmp/p2-desktop-full.png`.
- `browse` mobile(390): bridge 1열 + `↓`, 레일 세로 + `↓`, JSON/DB overflow 없음 확인. 스크린샷 `/tmp/p2-mobile-full.png`.

### 회귀 위험

- 레일은 `overflow-x: auto`로 매우 좁은 데스크톱 폭에서 가로 스크롤될 수 있다. 1440에서는 한 줄에 모두 들어옴.
- Delivery 레일 단계는 아직 `flow.value`(예: `failed`)를 평문으로 보여준다. not-configured 중립 칩 프레이밍은 Phase 3에서 적용한다.
- 폴링 중 발견한 SDK boot 401/favicon 404는 리디자인과 무관한 기존 동작(플러그인 키 미설정). 편집 중 잠깐 보인 status 500은 reload 타이밍 이슈로, 최종 상태는 200.

### 개선사항

- Phase 3에서 inspector(API requests + payload)를 레일 단계와 시각적으로 연결하고, payload 패널 헤더의 `KEY MISSING / SECRET MISSING` 빨강을 중립 문구로 바꾼다.
- Phase 4에서 identity-counters를 bridge와 더 분명히 구분되는 보조 통계 띠로 마무리한다.

### 다음 phase 계획 변경

- 변경 없음. input/output primitive 색 확정값(teal `#9fc4bd`/`#eef5f3`/`#2f6f68`, amber `#e0c089`/`#faf3e3`/`#9a6b16`)을 00-project-brief.md 시각 토큰 표 기준으로 사용한다.

## Phase 3: Stage-Artifact Linking & State Framing

완료일: 2026-06-11
커밋: 2842fa4

### 완료한 것

- 각 레일 단계를 자기 아티팩트와 묶었다: User API 단계는 실제 `GET /open/v5/users/@{memberId}` 경로(input 색), S2S Purchase 단계는 `POST /open/v5/users/{userId}/events` 경로(output 색), Delivery 단계는 `deliveryState` 상태 칩 + 실제 실패 시 `last_error`를 표시한다.
- 떠 있던 "API requests" 박스(request-grid)를 제거하고, 경로를 단계 안으로 이동해 "이 단계 = 이 호출"이 위치로 드러나게 했다.
- inspector를 payload 단독 패널로 정리하고 헤더에 `server-generated · not browser SDK` 배지를 명시했다(브라우저 SDK가 아니라 서버 생성 구매 이벤트임을 표시).
- 상단에 headline delivery 상태 strip을 추가했다: `S2S delivery [deliveryState chip] · credentialNote`. 로그인 직후 기본 화면이 중립 `NOT_CONFIGURED · demo · credentials not set`로 보이고, 빨강 FAILED 첫인상이 사라졌다.
- `not_configured` 칩을 중립 회색으로, 실제 `failed`는 빨강으로 유지해 둘을 분리했다. **실제 실패는 숨기지 않는다.**
- inline JS: `renderFlow(data)`로 시그니처를 바꿔 requests/identity/records를 소비, `render`에서 deliveryState 칩과 credentialNote를 갱신, 제거된 request/serverCredentials 갱신 코드 정리.

### 검증한 것

- `bin/rails test` (65 runs, 380 assertions, 0 failures).
- 라이브 status endpoint `200`, 폴링 중 board 관련 신규 콘솔 에러 없음(기존 ChannelTalk SDK boot 401만, 리디자인 무관).
- `browse` desktop(1440): status strip 중립 NOT_CONFIGURED, 단계별 API 경로 노출, payload 배지 확인. `/tmp/p3-desktop-fold.png`, `/tmp/p3-desktop-full.png`.
- `browse` mobile(390): 동일 구조 세로 접힘 확인. `/tmp/p3-mobile-full.png`.
- 칩 색 분리 확인(computed style): `not_configured = rgb(231,226,219)` 중립, `failed = rgb(245,216,208)` 빨강. honest-failure 경로가 빨강으로 렌더됨을 확인.

### 회귀 위험

- 실제 채널톡 credential이 없어 `failed`(credentials 있는 실제 실패) 상태의 라이브 스크린샷은 못 찍었다. 분류 로직은 Phase 1 모델 테스트로, 빨강 렌더는 computed style 비교로 확인했다.
- `.request-grid span` 셀렉터가 공용 라벨 규칙에 남아 있으나 매칭되는 마크업이 없어 무해하다.

### 개선사항

- Phase 4에서 변화 펄스, 단계형 버튼 라벨, DB record 위계화, identity-counters 보조 띠 마무리를 진행한다.

### 다음 phase 계획 변경

- 변경 없음.

## Phase 4: Change Highlight, Stepped Actions & DB Hierarchy

완료일: 2026-06-11
커밋: (phase 4 commit)

### 완료한 것

- 변화 하이라이트: `render`에서 직전 폴링 값과 비교해 바뀐 카운터(`purchaseEvents`/`orders`/`deliveries`), 상태 칩(`deliveryState`/`mappingStatus`), 변경된 DB 테이블에 0.6초 box-shadow ring 펄스를 적용했다. 첫 렌더는 펄스하지 않고(`hasRendered` 플래그), 순수 client-side 비교라 추가 API 호출이 없다. `prefers-reduced-motion: reduce`에서 펄스를 끈다.
- 단계형 액션 버튼: `① Create purchase`, `② Send to ChannelTalk`(둘 다 primary), `Refresh`(보조 `refresh-button`)로 발표 순서를 드러냈다. data-demo-action 기반이라 실제 동작은 그대로다.
- DB record 위계화: 스토리 핵심 3개(`channel_user_mappings`, `events`, `channel_event_deliveries`)를 먼저, `users`/`orders`를 뒤/muted로 정렬했다. core 테이블 제목에 amber 좌측 보더 액센트.
- 식별자 색 인코딩: `member_id`(input teal), `channel_user_id`(output amber)를 `channel_user_mappings`와 `channel_event_deliveries` 행에서 색으로 강조해, 매핑 row가 아직 없어도(`userId` not synced) deliveries 행에서 두 식별자가 나란히 색으로 보인다.
- raw ISO 타임스탬프를 `toLocaleTimeString()` 시:분:초로 표시.

### 검증한 것

- `bin/rails test` (65 runs, 384 assertions, 0 failures). 컨트롤러 테스트의 버튼 라벨 단언을 새 라벨로 갱신하고 `.identity-bridge`, `[data-field='deliveryState']` 구조 단언을 추가했다.
- 라이브 클릭 검증(새 서버 3002): `① Create purchase` 클릭 후 카운터 `pe 4→5, o 5→6, d 4→5` 증가, 동시에 6개 요소 펄스(`.pulse`) 발생 확인. `② Send to ChannelTalk` deliver action `200`.
- `browse` desktop/mobile: 단계형 버튼, DB core-first 정렬, deliveries 행의 `member_id` teal `rgb(47,111,104)` / `channel_user_id` amber `rgb(154,107,22)` 색 확인. `/tmp/p4-final-desktop.png`, `/tmp/p4-final-mobile.png`, `/tmp/p4-records2.png`.

### 회귀 위험

- **중요(환경)**: 3001 포트의 기존 dev 서버(pid 88888)는 `app/services` 디렉터리 추가 이전에 떠 있던 stale 프로세스라 `PurchaseOrder`를 autoload하지 못해 purchase action이 `500 NameError`를 낸다. 리디자인 코드 문제가 아니라 서버 재시작 필요. 검증은 새로 띄운 3002 서버에서 수행했다. **발표 전 Rails 서버를 재시작해야 purchase/deliver 액션이 동작한다.**
- 매핑 row가 실제로 생기는 경로(채널톡 User API 동기화)는 credential이 없어 라이브로 못 만들었다. deliveries 행 기준으로 식별자 색은 확인했다.

### 개선사항

- Phase 5에서 desktop/mobile 최종 회귀 확인, polling 비용(여전히 2초, count query 증가 없음) 확인, README의 보드 설명/발표 순서를 새 구조로 갱신한다.

### 다음 phase 계획 변경

- 변경 없음.
