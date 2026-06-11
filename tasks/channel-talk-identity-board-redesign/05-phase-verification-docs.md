# Phase 5: Verification & Docs

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

리디자인 전체를 실제 브라우저에서 검증하고, 회귀 위험을 점검하고, 발표용 문서를 갱신한다.

## 구현 범위

- **브라우저 검증**: 인증 세션으로 `/debug/channel/identity-flow`를 열어 desktop(1440)과 mobile(390) 폭에서:
  - bridge 변환 카드, 연결형 레일, 단계↔아티팩트 연결, 상태 프레이밍, 변화 펄스, DB 위계가 모두 의도대로 보이는지 확인.
  - 모바일에서 레일 세로 접힘, JSON/DB 가로 overflow 없음 확인.
  - `Create purchase` → `Send to ChannelTalk` 순서로 클릭해 값 변화와 펄스가 보이는지 확인.
- **회귀 점검**:
  - `bin/rails test` 전체 통과.
  - polling이 여전히 2초이고 status query 수가 리디자인 전과 같은지 확인(count query 추가 없음).
  - 기존 `/debug/channel` SDK payload 화면과 역할이 겹치지 않는지 확인.
- **문서 갱신**:
  - 프로젝트 README의 `/debug/channel/identity-flow` 설명/발표 순서를, 새 보드 구조(bridge → rail → artifact → DB)에 맞게 갱신한다.
  - 필요하면 [tasks/channel-talk-identity-demo-board](../channel-talk-identity-demo-board)의 completion-log에 "후속 리디자인은 channel-talk-identity-board-redesign 참조" 한 줄 포인터를 남긴다.

## 검증 방법

- `bin/rails test`
- `browse`로 desktop/mobile 스크린샷 캡처 및 before/after 비교.
- 클릭 흐름 수동 확인.

## 완료 조건

- desktop/mobile에서 리디자인이 깨짐 없이 의도대로 보인다.
- 전체 테스트 통과, polling 비용 회귀 없음.
- README가 새 보드 구조를 반영한다.
- `completion-log.md`에 최종 완료 내용, 검증, 남은 위험, 개선사항을 기록한다.
