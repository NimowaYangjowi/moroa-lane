# Phase 2: Visual Board

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

면접에서 바로 보여줄 수 있는 전용 페이지를 만든다. 긴 설명 없이 플로우차트, API request, S2S payload, DB 레코드가 중심이다.

## 구현 범위

- `/debug/channel/identity-flow` page
- `GET /debug/channel/identity-flow/status` polling
- `POST /debug/channel/identity-flow/purchase` demo purchase action
- `POST /debug/channel/identity-flow/deliver` delivery run action
- 상단 identity summary
- 플로우차트형 stage board
- User API request viewer
- S2S Event API payload viewer
- 실제 DB record table
- `Create demo purchase`, `Run delivery now`, `Refresh` 버튼
- JavaScript polling으로 상태 자동 갱신
- `ChannelIdentityDemoSnapshot` response key 기준으로 DOM 업데이트
- 반응형 CSS

## UI 원칙

- 큰 설명 문단을 만들지 않는다.
- 상태는 chip으로 표시한다.
- JSON은 monospace block으로 보여준다.
- DB record는 key/value table로 보여준다.
- 색은 상태 역할에만 쓴다: identity, mapping, request, success, failure.
- 화면이 난잡해지지 않도록 2열 dashboard와 하단 DB 영역으로 제한한다.

## 검증 방법

- `bin/rails test`
- 브라우저에서 페이지 로딩 확인
- 버튼 클릭 후 delivery 상태가 갱신되는지 확인
- 모바일 너비에서 JSON과 DB 테이블이 겹치지 않는지 확인

## 완료 조건

- 면접 중 페이지 하나로 `memberId`, `userId`, mapping, S2S payload, DB 상태를 보여줄 수 있다.
- delivery 실패도 숨기지 않고 화면에 표시한다.
- `completion-log.md`에 완료 내용, 검증, 회귀 위험, 개선사항을 기록한다.
