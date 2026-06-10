# Project Brief: ChannelTalk S2S Purchase Event

## 문제 정의

현재 프로젝트에는 상품 조회, 회원가입, 로그인, 장바구니 담기 같은 행동 이벤트가 내부 `events` 테이블에 기록된다. 다음 단계에서는 구매 완료처럼 서버가 확실히 알고 있는 비즈니스 이벤트를 채널톡에 S2S 방식으로 보내야 한다.

사용자가 보는 기능으로는 “구매 완료 주문”이고, 채널톡 상담원이나 CRM 입장에서는 “이 고객이 실제로 구매했다”는 고신뢰 이벤트다. 이 이벤트가 채널톡에 연결되면 상담원은 고객의 구매 맥락을 보고 응대할 수 있고, 채널톡 CRM에서는 구매 여부를 기준으로 고객 세그먼트나 목표 달성을 판단할 수 있다.

## 목표

- 내부 이벤트 목록에 `purchase`를 추가한다.
- 구매 완료 시 `Order`를 기준으로 `purchase` 이벤트를 기록한다.
- 고객사의 `memberId`와 채널톡의 `userId`를 연결하는 매핑 구조를 만든다.
- `purchase` 이벤트를 채널톡 Open API의 S2S 이벤트로 전송한다.
- 전송 성공, 실패, 재시도 상태를 DB에 남긴다.
- phase마다 구현, 검증, 리뷰, 커밋, 문서 업데이트를 완료한다.

## 현재 코드 기준

- `ApplicationController#record_event`가 내부 이벤트 생성을 담당한다.
- `Event::NAMES`는 현재 `login`, `registration`, `content_view`, `add_to_cart`를 허용한다.
- `CartItemsController#create`는 `add_to_cart` 이벤트를 내부 DB에 기록한다.
- `User#member_id`는 채널톡에 넘기는 고객사 기준 회원 식별자다.
- `ChannelPayload`는 SDK boot payload를 만든다.
- `Order`, `OrderItem` 모델은 존재하지만 실제 checkout 생성 흐름은 아직 제한적이다.

## 목표 데이터 흐름

```text
사용자 구매 완료
-> Order 생성 또는 확정
-> Event(name: "purchase", subject: order) 생성
-> ChannelEventDelivery(status: "pending") 생성
-> ChannelEventDeliveryJob enqueue
-> ChannelUserMapping에서 channel_user_id 확인
-> 없으면 memberId로 채널톡 User 조회
-> POST /open/v5/users/{channel_user_id}/events
-> 성공 시 sent, 실패 시 failed 상태 기록
```

## 식별자 매핑

| 역할 | 프로젝트 값 | 채널톡 값 | 설명 |
|---|---|---|---|
| 고객사 회원 식별자 | `User#member_id` | `memberId` | Acme가 관리하는 안정적인 고객 키 |
| 채널톡 내부 User 식별자 | `ChannelUserMapping#channel_user_id` | `userId` | S2S Event API path에 필요한 채널톡 내부 키 |
| 내부 이벤트 식별자 | `Event#id` | 없음 | 우리 서비스에서 실제로 발생한 행동 이벤트 |
| 외부 이벤트 전송 식별자 | `ChannelEventDelivery#id` | `channel_event_id` | 채널톡 전송 상태와 응답 이벤트를 추적하는 키 |

## 포함 범위

- `purchase` 내부 이벤트 추가
- 구매 이벤트 payload 설계
- 채널톡 User 매핑 테이블
- 채널톡 이벤트 전송 상태 테이블
- 채널톡 API 클라이언트 또는 서비스 객체
- background job 기반 전송
- 실패 상태, 재시도 횟수, 마지막 오류 기록
- 모델/컨트롤러/job 테스트
- README와 데모 시나리오 업데이트

## 제외 범위

- 실제 결제 대행사 연동
- 실제 배송, 환불, 취소, 재고 차감
- 채널톡 Open API 전체 구현
- 채널톡 관리자 화면 자동 검증
- 대량 과거 이벤트 backfill
- 고객 개인정보를 과도하게 전송하는 payload 확장

## 회귀 위험

- checkout 흐름에 외부 API 호출을 직접 넣으면 구매 완료 응답이 느려질 수 있다.
- `memberId -> userId` 매핑 실패를 조용히 무시하면 채널톡 CRM에서 구매 이벤트가 누락된다.
- 내부 `Event`와 외부 delivery 상태를 한 테이블에 섞으면 재시도와 디버깅이 어려워진다.
- 채널톡 API 인증키가 없는 개발 환경에서 테스트가 불안정해질 수 있다.
- 중복 job 실행 시 같은 구매 이벤트가 채널톡에 여러 번 전송될 수 있다.
- delivery 상태 전환이 원자적으로 처리되지 않으면 retry job과 수동 재전송이 같은 이벤트를 동시에 보낼 수 있다.
