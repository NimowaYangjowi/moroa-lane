# Phase 2: Purchase Event

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

주문 생성 또는 checkout 완료 흐름에서 내부 `purchase` 이벤트를 기록한다. 이 phase의 결과물은 “우리 서비스에서 구매가 발생했다”는 신뢰 가능한 이벤트 원장이다.

## 구현 범위

- checkout 또는 demo purchase 액션 추가
- 장바구니 항목을 기반으로 `Order`와 `OrderItem` 생성
- 주문 생성 후 `Event(name: "purchase", subject: order)` 기록
- `ChannelEventDelivery(status: "pending")` 생성
- 주문 생성과 내부 이벤트 생성의 트랜잭션 경계 정의
- 구매 완료 후 장바구니 정리 여부 결정
- controller/model 테스트 추가

## 이벤트 payload 초안

```ruby
{
  order_id: order.id,
  total_cents: order.total_cents,
  currency: "KRW",
  item_count: order.order_items.sum(:quantity),
  product_ids: order.products.pluck(:id),
  product_names: order.products.pluck(:name)
}
```

채널톡에 보낼 payload는 Phase 3에서 별도 매퍼로 다듬는다. 내부 이벤트 payload는 주문 재현과 디버깅에 필요한 값 위주로 유지한다.

## 사용자 관점 설명

사용자는 장바구니에서 구매 완료 버튼을 누르고 주문 완료 상태를 확인한다. 내부적으로는 이 순간 `purchase` 이벤트가 생성되어, 나중에 상담원이 “이 고객이 어떤 상품을 구매했는지” 볼 수 있는 데이터의 출발점이 된다.

## 기술 포인트

- 주문 생성 실패 시 `purchase` 이벤트를 만들지 않는다.
- `purchase` 이벤트 생성 실패 시 주문을 커밋할지 롤백할지 구현 전에 결정한다. 추천은 같은 트랜잭션에서 처리해 내부 원장을 일관되게 유지하는 것이다.
- 채널톡 delivery 생성은 내부 이벤트 생성 직후 만든다.
- 채널톡 API 호출은 이 phase에서 하지 않는다.
- 실제 결제 성공 callback을 흉내 내는 수준으로 구현하고, 결제 대행사 연동은 범위에서 제외한다.

## 검증 방법

- `bin/rails test`
- 장바구니가 비어 있을 때 구매 완료가 생성되지 않는지 확인
- 장바구니가 있을 때 `Order`, `OrderItem`, `purchase Event`, `pending ChannelEventDelivery`가 생성되는지 테스트
- 구매 후 화면 이동과 flash 메시지가 기존 장바구니 UX를 깨지 않는지 수동 확인

## 완료 조건

- 구매 완료 흐름에서 내부 `purchase` 이벤트가 생성된다.
- `purchase` 이벤트는 `Order`를 subject로 가진다.
- 채널톡 전송 대기 delivery가 생성된다.
- 채널톡 API는 아직 호출하지 않는다.
- `completion-log.md`에 완료 내용, 검증, 회귀 위험, 개선사항을 기록한다.
