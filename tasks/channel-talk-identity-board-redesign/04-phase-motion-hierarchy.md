# Phase 4: Change Highlight, Stepped Actions & DB Hierarchy

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

"값이 움직인다"를 실제로 보이게 만들고(E), 발표 순서를 버튼에 새기며, 하단 DB record를 스토리 순서로 위계화한다(F). 디테일을 정리해 보드를 발표 가능한 완성도로 끌어올린다.

## 구현 범위 (E: change highlight)

[app/views/channel_identity_demo/show.html.erb](../../app/views/channel_identity_demo/show.html.erb)의 inline JS에서:

- `render()` 시 직전 값과 비교해, 바뀐 카운터(`purchaseEvents`/`orders`/`deliveries`), 상태 칩(`deliveryState`/`mappingStatus`), 변경된 DB 셀에 약 0.6초 배경 펄스 클래스를 추가했다가 제거한다.
- 순수 client-side 비교로 처리한다. 추가 fetch/API 호출을 만들지 않는다.
- pulse는 CSS `@keyframes`로 처리하고, `prefers-reduced-motion`을 존중한다.
- 첫 로드(직전 값 없음)에는 전체가 번쩍이지 않게 한다.

## 구현 범위 (단계형 액션 버튼)

- 버튼 라벨을 발표 순서로: `① Create purchase` → `② Send to ChannelTalk`(기존 Run delivery now), `Refresh`는 secondary로 시각 비중을 낮춘다.
- 데스크톱에서 Refresh가 어색하게 줄바꿈되던 군집을 정리한다(주 액션 2개 + 보조 1개 구조).
- 라벨이 길어져도 실제 동작(purchase action / delivery run / status refresh)은 그대로 유지한다.

## 구현 범위 (F: DB record hierarchy)

`renderRecords()`와 CSS에서:

- 스토리 핵심 3개를 위/강조 행으로: `channel_user_mappings`, `events`, `channel_event_deliveries`.
- `users`, `orders`는 보조 행으로 시각 비중을 낮춘다.
- `channel_user_mappings` 테이블에서 `member_id`(input 색)와 `channel_user_id`(output 색)를 나란히 강조해, 두 식별자가 한 행에 묶여 저장된다는 점을 보이게 한다.
- 5열 빽빽함을 완화한다(핵심 3 + 보조 2 그룹 레이아웃 또는 우선순위 정렬).

## 구현 범위 (디테일 정리)

- flow 헤더의 raw ISO 타임스탬프(`generatedAt`)를 사람이 읽기 쉬운 형식(예: `HH:MM:SS` 또는 `n초 전`)으로 표시한다.
- identity-counters를 bridge와 명확히 구분되는 보조 통계 띠로 마무리한다.

## 검증 방법

- `bin/rails test`
- 브라우저에서 `① Create purchase` 클릭 → 카운터/DB 셀 펄스가 보이는지 확인.
- `② Send to ChannelTalk` 클릭 → delivery 상태 칩 전환 + 펄스 확인.
- `prefers-reduced-motion` 설정 시 펄스가 비활성되는지 확인.
- DB record에서 핵심 3개 강조와 mappings의 member_id/channel_user_id 색 대비 확인.
- `browse` desktop/mobile 스크린샷 캡처.

## 완료 조건

- 클릭/polling으로 바뀐 값이 펄스로 강조돼 "값이 움직였다"가 보인다.
- 버튼이 발표 순서를 드러낸다.
- DB record가 스토리 순서로 위계화되고 mappings 행이 강조된다.
- `completion-log.md`에 완료 내용, 검증, 회귀 위험, 개선사항을 기록한다.
