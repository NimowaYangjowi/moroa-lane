# Phase 1: Data Model

## 공통 진행 지시사항

- 이 phase가 끝나면 반드시 커밋한다.
- 커밋 전에 자동 테스트와 필요한 수동 확인을 수행하고, 확인한 명령이나 화면을 기록한다.
- phase 종료 시 회귀 위험과 개선사항을 리뷰한다.
- 완료한 내용, 검증 결과, 남은 위험, 개선사항은 `completion-log.md`에 업데이트한다.
- 구현 중 배운 내용 때문에 남은 작업 순서나 범위가 달라지면 이후 phase 문서도 함께 업데이트한다.
- 계획과 실제 구현이 다르면 실제 구현을 기준으로 문서를 고친다.
- 외부 API 실패를 숨기는 fallback을 추가하지 않는다. 실패 원인과 재시도 상태를 추적할 수 있게 남긴다.
- DB trigger는 사용하지 않는다. 구매 후속 작업은 모델, 서비스, job처럼 코드에서 보이는 경로로 처리한다.
- 기존 작업자의 변경 사항을 되돌리지 않는다. unrelated dirty worktree는 그대로 두고 필요한 파일만 좁게 수정한다.

## 목표

`purchase` 내부 이벤트와 채널톡 S2S 전송에 필요한 DB 구조를 만든다. 이 phase는 아직 채널톡 API를 호출하지 않는다.

## 구현 범위

- `Event::NAMES`에 `purchase` 추가
- `channel_user_mappings` 테이블 추가
- `channel_event_deliveries` 테이블 추가
- 모델 validation과 association 추가
- 중복 전송 방지용 unique index 추가
- fixture 또는 test data 추가

## 제안 테이블

### `channel_user_mappings`

- `user_id`: 내부 사용자
- `member_id`: 채널톡에 넘기는 고객사 기준 키
- `channel_user_id`: 채널톡 내부 User ID
- `synced_at`: 마지막으로 매핑을 확인한 시간
- `last_error`: 마지막 매핑 실패 이유
- timestamps

권장 제약:

- `user_id` unique
- `member_id` unique
- `channel_user_id` unique, null 허용 여부는 구현 시 결정

### `channel_event_deliveries`

- `event_id`: 내부 이벤트
- `user_id`: 내부 사용자
- `channel_user_mapping_id`: 매핑 레코드, 처음에는 null 가능
- `member_id`: 전송 당시의 고객사 회원 키
- `channel_user_id`: 전송 당시의 채널톡 User ID
- `status`: `pending`, `processing`, `sent`, `failed`
- `channel_event_id`: 채널톡 응답 이벤트 ID
- `attempts`: 전송 시도 횟수
- `last_error`: 마지막 실패 이유
- `sent_at`: 성공 전송 시간
- timestamps

권장 제약:

- `event_id` unique
- `status` inclusion validation
- `attempts`는 0 이상
- `processing` 상태가 오래 남은 delivery를 다시 점검할 수 있도록 timestamps를 활용한다.

## 사용자 관점 설명

구매 이벤트는 고객이 주문을 완료했다는 신뢰도 높은 기록이다. 매핑 테이블은 Acme가 아는 고객 ID와 채널톡이 아는 고객 ID를 연결하는 명단이고, 전송 테이블은 그 구매 기록이 채널톡까지 제대로 전달됐는지 확인하는 배송 추적표 역할을 한다.

## 검증 방법

- `bin/rails db:migrate`
- `bin/rails test`
- `Event.new(name: "purchase", ...)`가 valid인지 확인
- 같은 내부 이벤트로 delivery를 두 번 만들 수 없는지 테스트
- 필수 식별자와 상태 validation 테스트

## 완료 조건

- 내부 이벤트 원장과 채널톡 전송 상태가 분리되어 있다.
- 채널톡 전송 실패를 추적할 DB 필드가 있다.
- 중복 전송을 DB 제약 또는 validation으로 막는다.
- 전송 중 상태를 표현할 수 있어 동시 job 실행 위험을 줄일 수 있다.
- `completion-log.md`에 완료 내용, 검증, 회귀 위험, 개선사항을 기록한다.
