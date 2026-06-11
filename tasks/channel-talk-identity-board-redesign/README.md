# ChannelTalk Identity Board Redesign Plan

이 폴더는 `/debug/channel/identity-flow` 데모 보드의 UI를 "값이 흐르는 모습"이 한 화면에서 읽히도록 다시 디자인하는 계획을 담는다.

기존 보드([tasks/channel-talk-identity-demo-board](../channel-talk-identity-demo-board))는 필요한 데이터(identity, flow, API request, payload, DB record)를 모두 노출하지만, 같은 모양의 카드가 평평하게 나열돼 있어 "조회는 `memberId`로, 이벤트 전송은 `userId`로"라는 핵심 변환이 시각적으로 드러나지 않는다. 발표자가 결국 말로 단계를 이어줘야 한다.

이 리디자인의 목표는 발표 중 말로 잇지 않아도 화면 구조만으로 **식별자 → 변환 → API → payload → DB row → delivery 상태**가 좌에서 우로 한 문장처럼 읽히게 만드는 것이다.

## 공통 진행 지시사항

모든 phase 문서의 최상단에도 같은 지시사항을 둔다. 구현 중에는 각 phase마다 아래 순서를 지킨다.

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

## 화면 목표

- `memberId`(input, Acme가 만든 키)와 `userId`(output, 채널톡이 발급한 키)의 **변환**이 화살표와 색으로 한 눈에 보인다.
- 6단계 flow가 방향이 분명한 한 줄 레일로 연결돼 시선이 좌→우로 흐른다.
- 각 단계가 자기 API 호출/payload/DB row와 색·위치로 묶여 있다.
- 자격증명 미설정 상태가 "고장난 빨강"이 아니라 중립 "demo · not configured"로 보인다.
- `Create demo purchase` / `Run delivery now` 클릭 시 바뀐 값이 모션으로 강조돼 "값이 움직였다"가 보인다.
- 설명 문장은 짧은 라벨 수준으로 제한한다.

## 문서 구조

- [00-project-brief.md](./00-project-brief.md): 리디자인 목적, 현행 문제 정리, 새 정보 구조와 시각 토큰 기준
- [01-phase-snapshot-data.md](./01-phase-snapshot-data.md): snapshot에 key 역할·상태 분류 데이터 추가, 테스트
- [02-phase-bridge-rail.md](./02-phase-bridge-rail.md): identity bridge 변환 카드 + 연결형 가로 레일 flowchart (A, B)
- [03-phase-artifact-state.md](./03-phase-artifact-state.md): 단계↔API/payload/delivery 연결, not-configured vs failed 상태 프레이밍 (C, D)
- [04-phase-motion-hierarchy.md](./04-phase-motion-hierarchy.md): 변화 하이라이트, 단계형 액션 버튼, DB record 위계화, 반응형 (E, F)
- [05-phase-verification-docs.md](./05-phase-verification-docs.md): desktop/mobile 브라우저 검증, 회귀 리뷰, README 갱신
- [review-template.md](./review-template.md): phase 종료 리뷰 템플릿과 리뷰 기준
- [completion-log.md](./completion-log.md): 완료한 phase와 변경된 계획 기록

## 권장 커밋 단위

- `phase 0: plan identity board redesign`
- `phase 1: add identity board redesign snapshot data`
- `phase 2: build identity bridge and connected rail`
- `phase 3: link stages to api payload and reframe delivery state`
- `phase 4: add change highlight, stepped actions, db hierarchy`
- `phase 5: verify identity board redesign`

## 범위

- 대상 화면: `/debug/channel/identity-flow` 한 화면.
- 변경 파일은 [app/views/channel_identity_demo/show.html.erb](../../app/views/channel_identity_demo/show.html.erb), [app/assets/stylesheets/application.css](../../app/assets/stylesheets/application.css)의 identity-demo 블록, 필요한 만큼의 [app/models/channel_identity_demo_snapshot.rb](../../app/models/channel_identity_demo_snapshot.rb)와 해당 테스트로 좁게 제한한다.
- 데이터 의미는 바꾸되 honest failure 원칙은 유지한다. delivery 실제 실패는 계속 실패로 보여준다.

## 제외 범위

- 차트/그래프 라이브러리 도입.
- 실제 채널톡 Open API 호출 방식이나 S2S delivery 로직 변경.
- 인증/주문/장바구니 등 데모 보드 밖 화면 변경.
- 운영용 대시보드 수준의 집계·페이지네이션 재설계.
