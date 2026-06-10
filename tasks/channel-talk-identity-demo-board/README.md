# ChannelTalk Identity Demo Board Plan

이 폴더는 채널톡 사전면접 시나리오를 보여주는 라이브 데모 보드 구현 계획을 담는다.

목표는 긴 설명 페이지가 아니라, `memberId`와 `userId`의 차이, User API 조회 순서, 내부 DB 매핑, S2S `Purchase` 이벤트 전송 payload를 한 화면에서 보여주는 발표용 화면을 만드는 것이다.

## 공통 진행 지시사항

모든 phase 문서의 최상단에도 같은 지시사항을 둔다. 구현 중에는 각 phase마다 아래 순서를 지킨다.

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

## 화면 목표

- `memberId`는 Acme가 만든 고객 키로 보인다.
- `userId`는 채널톡 User API로 얻은 채널톡 내부 키로 보인다.
- `GET /open/v5/users/@{memberId}`와 `POST /open/v5/users/{userId}/events`가 다른 역할을 한다는 점이 보인다.
- `users`, `events`, `channel_user_mappings`, `channel_event_deliveries`, `orders`의 실제 최신 레코드가 보인다.
- `pending -> processing -> sent/failed` 상태가 자동 갱신된다.
- 설명 문장은 짧은 라벨 수준으로 제한한다.

## 문서 구조

- [00-project-brief.md](./00-project-brief.md): 목적, 면접 시나리오 연결, 화면 정보 구조
- [01-phase-data-endpoints.md](./01-phase-data-endpoints.md): demo board presenter, JSON 상태 endpoint, 테스트
- [02-phase-visual-board.md](./02-phase-visual-board.md): 플로우차트, payload viewer, DB 레코드 UI, polling
- [03-phase-verification-docs.md](./03-phase-verification-docs.md): 브라우저 확인, 문서 정리, 회귀 리뷰
- [review-template.md](./review-template.md): phase 종료 리뷰 템플릿
- [completion-log.md](./completion-log.md): 완료한 phase와 변경된 계획 기록

## 권장 커밋 단위

- `phase 0: plan channel identity demo board`
- `phase 1: expose identity demo board data`
- `phase 2: build channel identity demo board`
- `phase 3: verify identity demo board`
