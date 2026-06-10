# ChannelTalk S2S Purchase Event Plan

이 폴더는 현재 커머스 시뮬레이터의 내부 이벤트 기록 구조를 확장해, 구매 완료 이벤트를 채널톡 S2S Event API로 연동하는 작업 계획을 담는다.

목표는 실제 결제 대행사 연동을 만드는 것이 아니라, 고객사 서버에서 발생한 신뢰도 높은 구매 이벤트를 채널톡 User에 연결해 상담 맥락과 CRM 이벤트로 활용하는 흐름을 구현하는 것이다.

## 프로젝트 한 줄 설명

현재 `add_to_cart`처럼 내부 `events` 테이블에 기록되는 행동 이벤트 구조를 유지하면서, `purchase` 이벤트를 주문 단위로 기록하고 `memberId -> channel userId` 매핑을 거쳐 채널톡 Open API의 `POST /open/v5/users/{userId}/events`로 전송한다.

## 공통 진행 지시사항

모든 phase 문서의 최상단에도 같은 지시사항을 둔다. 구현 중에는 각 phase마다 아래 순서를 지킨다.

- 이 phase가 끝나면 반드시 커밋한다.
- 커밋 전에 자동 테스트와 필요한 수동 확인을 수행하고, 확인한 명령이나 화면을 기록한다.
- phase 종료 시 회귀 위험과 개선사항을 리뷰한다.
- 완료한 내용, 검증 결과, 남은 위험, 개선사항은 `completion-log.md`에 업데이트한다.
- 구현 중 배운 내용 때문에 남은 작업 순서나 범위가 달라지면 이후 phase 문서도 함께 업데이트한다.
- 계획과 실제 구현이 다르면 실제 구현을 기준으로 문서를 고친다.
- 외부 API 실패를 숨기는 fallback을 추가하지 않는다. 실패 원인과 재시도 상태를 추적할 수 있게 남긴다.
- DB trigger는 사용하지 않는다. 구매 후속 작업은 모델, 서비스, job처럼 코드에서 보이는 경로로 처리한다.
- 기존 작업자의 변경 사항을 되돌리지 않는다. unrelated dirty worktree는 그대로 두고 필요한 파일만 좁게 수정한다.

## 구현 원칙

- 내부 이벤트 원장과 채널톡 전송 상태를 분리한다.
- 구매 이벤트의 기준 subject는 `Order`로 둔다.
- 고객사 기준 식별자는 `User#member_id`로 유지한다.
- 채널톡 S2S API에 필요한 `userId`는 별도 매핑 테이블에서 관리한다.
- 외부 API 호출은 checkout 요청 경로에서 직접 수행하지 않고 background job에서 처리한다.
- 구매 자체와 채널톡 이벤트 전송은 결합하지 않는다. 채널톡 장애가 구매 완료 UX를 막으면 안 된다.
- 중복 전송을 막기 위해 내부 이벤트 또는 delivery 단위에 고유 제약을 둔다.
- rate limit, 인증 실패, 네트워크 실패는 상태와 오류 메시지로 남긴다.

## 문서 구조

- [00-project-brief.md](./00-project-brief.md): 목표, 데이터 흐름, 식별자 매핑, 제외 범위
- [01-phase-data-model.md](./01-phase-data-model.md): `purchase` 이벤트와 채널톡 매핑/전송 상태 DB 구조
- [02-phase-purchase-event.md](./02-phase-purchase-event.md): 주문 생성 또는 checkout 완료 흐름에서 내부 `purchase` 이벤트 기록
- [03-phase-channel-s2s-delivery.md](./03-phase-channel-s2s-delivery.md): 채널톡 User 조회, S2S Event API 전송, 재시도와 실패 상태
- [04-phase-verification-docs.md](./04-phase-verification-docs.md): 테스트, 문서, 데모 시나리오, 회귀 리뷰
- [review-template.md](./review-template.md): phase 종료 리뷰 템플릿
- [completion-log.md](./completion-log.md): 완료한 phase와 변경된 계획 기록

## 권장 커밋 단위

- `phase 1: add channel s2s event data model`
- `phase 2: record purchase events from checkout`
- `phase 3: deliver purchase events to channel talk`
- `phase 4: verify s2s purchase flow and docs`
