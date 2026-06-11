# Phase 2: Identity Bridge & Connected Rail

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

보드의 시각 중심을 만든다. 발표 핵심인 `memberId → userId` 변환을 주인공으로 세우고(A), 6단계를 방향이 분명한 한 줄 레일로 연결한다(B). 이 phase가 "값이 흐른다"를 시각적으로 성립시키는 핵심이다.

## 구현 범위 (A: identity bridge)

[app/views/channel_identity_demo/show.html.erb](../../app/views/channel_identity_demo/show.html.erb)의 기존 `identity-summary` 4칸을 하나의 변환 카드(identity bridge)로 교체한다.

- 좌측: `memberId` 값 + `input · Acme가 만든 키` 라벨, identity-input 색.
- 중앙: 화살표 + 그 위에 `GET @memberId` (User API lookup) 표기.
- 우측: `userId` 값 또는 `mappingStatus` 기반 상태(`not synced yet` 등) + `output · 채널톡이 발급` 라벨, identity-output 색.
- 값 폭이 길어도(UUID) 줄바꿈이 카드 균형을 깨지 않게 monospace + 적절한 truncation/wrap 처리.
- 이 카드는 board 최상단(액션 바로 아래)에 두어 첫 시선이 변환에 닿게 한다.

JS `render()`는 `data.identity.memberId`, `data.identity.channelUserId`, `data.identity.mappingStatus`를 bridge DOM에 채운다.

## 구현 범위 (B: connected rail flowchart)

기존 `identity-stage-list`(3열×2행 그리드)를 화살표로 연결된 가로 레일로 교체한다.

- 6단계 순서: Acme user → memberId → User API → Mapping DB → S2S Purchase → Delivery.
- 단계 카드 사이에 방향 화살표(→)를 그린다. CSS pseudo-element 또는 명시적 구분자 노드로 처리한다.
- 각 단계 보더/배경을 Phase 1의 `flow[].keyRole`로 칠한다: `input` → identity-input 색, `output` → identity-output 색.
- 마지막 Delivery 단계에는 상태 칩(Phase 3에서 not-configured 분류 연결)을 둔다.
- 데스크톱: 가로 한 줄(필요 시 가로 스크롤 허용, 단 6단계가 1440 폭에서 한 줄에 들어오게 카드 폭 조정).
- 모바일/좁은 폭: 세로 레일로 접되 단계 사이 화살표(↓)는 유지한다.

JS `renderFlow()`를 새 마크업(화살표 포함, keyRole 색 적용)에 맞게 수정한다.

## UI 원칙

- bridge 카드와 레일이 같은 input/output 색 언어를 공유해, "어느 단계가 어느 키를 쓰는지"가 두 영역에서 일관되게 보인다.
- 색은 역할에만 쓴다. 장식 목적의 색은 추가하지 않는다.
- 설명 문단을 넣지 않는다. 단계 라벨 + 값 + 짧은 역할 캡션만 둔다.
- 기존 `identity-counters`(Purchase events/Orders/Deliveries)는 이 phase에서 유지하되, bridge와 시각적으로 구분되도록 위계를 낮춘다(보조 통계 띠). 본격 위계 정리는 Phase 4에서 한다.

## 검증 방법

- `bin/rails test`
- 브라우저 desktop(1440)에서 bridge 카드의 input/output 색 대비와 화살표가 보이는지 확인.
- 레일이 1440에서 한 줄로, 모바일(390)에서 세로로 접히고 화살표가 유지되는지 확인.
- `browse`로 desktop/mobile 스크린샷 캡처해 completion-log에 첨부 경로 기록.

## 완료 조건

- 화면 최상단에서 `memberId → userId` 변환이 색+화살표로 한 눈에 읽힌다.
- 6단계가 방향 있는 레일로 연결되고 input/output 색으로 키 전환 지점이 드러난다.
- desktop/mobile 모두 깨짐 없이 표시된다.
- `completion-log.md`에 완료 내용, 검증, 회귀 위험, 개선사항을 기록한다.
