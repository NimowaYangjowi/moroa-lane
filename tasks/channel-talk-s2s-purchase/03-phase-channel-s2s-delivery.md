# Phase 3: ChannelTalk S2S Delivery

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

`pending` 상태의 구매 이벤트 delivery를 채널톡 Open API로 전송한다. 이 phase는 `memberId -> channel userId` 매핑 확인과 S2S 이벤트 생성이 핵심이다.

## 구현 범위

- 채널톡 Open API 클라이언트 또는 서비스 객체 추가
- API 인증 환경변수 추가
- `memberId`로 채널톡 User 조회
- `channel_user_mappings` upsert 또는 갱신
- `POST /open/v5/users/{userId}/events` 호출
- `ChannelEventDeliveryJob` 추가
- 전송 시작 시 `processing`, 성공 시 `sent`, 실패 시 `failed` 상태 기록
- 네트워크/API 호출 테스트를 위한 stub 추가

## 환경변수

- `CHANNELTALK_ACCESS_KEY`
- `CHANNELTALK_ACCESS_SECRET`
- `CHANNELTALK_API_BASE_URL`, 기본값은 `https://api.channel.io`

인증키가 없으면 전송 job은 명확히 실패 상태를 남기거나 실행을 막아야 한다. 조용히 성공 처리하거나 더미 응답을 만들지 않는다.

## 전송 payload 초안

```json
{
  "name": "Purchase",
  "property": {
    "orderId": "123",
    "totalCents": 64000,
    "currency": "KRW",
    "itemCount": 2,
    "productNames": ["Glass Dew Serum", "Cloud Barrier Cream"]
  }
}
```

내부 이벤트명은 `purchase`로 유지하고, 채널톡에 표시될 이벤트명은 `Purchase`로 변환한다.

## 사용자 관점 설명

구매가 끝난 뒤 상담원이 채널톡에서 고객을 보면, 이 고객이 구매 완료 이벤트를 가진 상태가 된다. 상담원은 구매 직후 문의인지, 장바구니만 담고 이탈한 고객인지 구분할 수 있다.

## 기술 포인트

- 채널톡 S2S Event API는 `memberId`가 아니라 채널톡 내부 `userId`를 path로 요구한다.
- 매핑이 없으면 `GET /open/v5/users/@{memberId}`로 채널톡 User를 먼저 조회한다.
- 채널톡 User 조회 실패와 Event 생성 실패는 구분해서 기록한다.
- retry는 bounded retry로 제한하고, retry 대상은 명시적인 상태 전환으로 다시 `pending`에 넣는다.
- 같은 `ChannelEventDelivery`가 동시에 두 번 전송되지 않도록 `pending -> processing` 전환을 원자적으로 처리한다.
- API 응답의 채널톡 event ID가 있으면 `channel_event_id`에 저장한다.

## 검증 방법

- `bin/rails test`
- 채널톡 User 조회 성공 시 mapping이 저장되는지 테스트
- delivery가 `pending`에서 `processing`으로 바뀐 뒤 전송되는지 테스트
- 채널톡 Event 전송 성공 시 delivery가 `sent`가 되는지 테스트
- 인증 실패, 404, rate limit, 네트워크 실패가 `last_error`와 attempts에 남는지 테스트
- 실제 API 키가 있을 때 수동으로 한 건 전송하고 채널톡에서 이벤트 표시를 확인한다.

## 완료 조건

- pending delivery가 background job으로 채널톡에 전송된다.
- `memberId -> channel userId` 매핑이 DB에 저장된다.
- 실패 원인이 DB에 남는다.
- 동시 실행 상황에서 같은 delivery를 중복 전송하지 않는 상태 전환 기준이 있다.
- 테스트는 외부 네트워크에 의존하지 않는다.
- `completion-log.md`에 완료 내용, 검증, 회귀 위험, 개선사항을 기록한다.
