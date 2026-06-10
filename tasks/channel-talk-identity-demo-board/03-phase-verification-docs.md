# Phase 3: Verification And Docs

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

데모 보드를 실제 면접 흐름에 맞춰 검증하고 README와 task log를 최신화한다.

## 구현 범위

- 전체 test suite 실행
- browser QA
- README demo flow 업데이트
- completion log 업데이트
- 남은 회귀 위험 정리

## 검증 방법

- `bin/rails test`
- 로컬 서버에서 `/debug/channel/identity-flow` 접속
- demo purchase 생성
- delivery run
- JSON polling 업데이트 확인
- desktop/mobile 화면 확인

## 완료 조건

- 데모 보드 URL과 사용 순서를 README에서 찾을 수 있다.
- 화면이 면접 질문의 `memberId`/`userId` 차이를 실제 값으로 보여준다.
- 모든 phase가 커밋되어 있다.
