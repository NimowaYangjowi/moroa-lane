# Phase 3: Stage-Artifact Linking & State Framing

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

레일의 각 단계를 자기 API 호출·payload·delivery 결과와 시각적으로 묶고(C), 자격증명 미설정 상태를 "고장난 빨강"이 아니라 중립 상태로 정직하게 프레이밍한다(D).

## 구현 범위 (C: stage ↔ artifact linking)

- **User API 단계 → request 경로**: User API 단계 카드 또는 인접 패널에 `GET /open/v5/users/@{memberId}` 경로를 붙인다. memberId 부분을 input 색으로 강조해 "이 단계가 이 호출"이 보이게 한다.
- **S2S Purchase 단계 → request + payload**: S2S Purchase 단계에 `POST /open/v5/users/{userId}/events` 경로와 payload JSON을 연결한다. userId 부분을 output 색으로 강조한다.
- **Delivery 단계 → 결과**: status / attempts / last_error를 Delivery 단계에 붙인다.
- payload 패널 헤더에 `server-generated · not browser SDK` 배지를 명시해, 이 데이터가 브라우저 SDK 이벤트가 아니라 서버가 만든 구매 이벤트임을 드러낸다.
- 기존 `request-grid`/`payload-panel`은 재사용하되, 위치/연결선/색으로 어느 단계 소속인지 보이게 한다. 별도 독립 상자로 떠 있지 않게 한다.

## 구현 범위 (D: state framing)

- Phase 1의 `deliveryState`를 기준으로 상태 칩을 칠한다.
  - `not_configured` → 중립 회색 칩 + `demo · credentials not set` 라벨. 빨강 사용 금지.
  - `failed` (credentials 있는 실제 실패) → 기존 빨강 유지 + `last_error` 노출.
  - `sent`/`synced` → green, `processing`/`pending`/`waiting` → amber.
- payload 패널 헤더의 기존 `KEY MISSING / SECRET MISSING` 빨강 텍스트를, credentials 미설정 시 중립 `credentials not set (demo mode)`로 바꾼다. credentials가 있으면 정상 표기.
- 헤드라인 Delivery 칩(상단)도 같은 `deliveryState` 분류를 쓴다. 로그인 직후 기본 화면이 "고장"처럼 보이지 않게 한다.
- **실제 실패는 계속 빨강 + 원인 노출.** not-configured와 failed를 절대 합치지 않는다.

## UI 원칙

- 한 단계의 "값 → 호출 → 결과"가 위치/색으로 한 묶음처럼 읽혀야 한다.
- not-configured 회색과 failed 빨강은 시각적으로 분명히 달라야 한다.
- 설명 문단 대신 짧은 라벨과 칩으로 상태 의미를 전달한다.

## 검증 방법

- `bin/rails test`
- credentials 미설정 상태(로컬 기본)에서: 상단/Delivery 칩이 중립 not-configured로 보이고 빨강 FAILED가 사라졌는지 확인.
- payload 패널 헤더가 중립 문구로 바뀌었는지 확인.
- (가능하면) credentials를 임시로 넣고 실제 실패를 유도해 빨강 failed + last_error가 그대로 노출되는지 확인. 불가하면 회귀 위험에 기록.
- `browse` desktop/mobile 스크린샷 캡처.

## 완료 조건

- 각 단계가 자기 API 경로/payload/delivery 결과와 시각적으로 묶인다.
- payload가 server-generated임이 명시된다.
- 자격증명 미설정이 중립 상태로, 실제 실패가 빨강으로 분리돼 보인다.
- `completion-log.md`에 완료 내용, 검증, 회귀 위험, 개선사항을 기록한다.
