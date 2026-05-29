# Project Brief

## 목적

이 프로젝트는 채널톡 기술면접에서 사용할 작은 커머스 시뮬레이션이다. 사용자가 상품을 보고, 회원가입하거나 로그인하고, 장바구니와 주문 이력을 가진 고객이 된 뒤, 채널톡 상담창에 어떤 고객 정보가 넘어가는지 설명하는 데 초점을 둔다.

완성형 쇼핑몰이 아니라 연동 설명용 데모다. 사용자가 보는 화면은 쇼핑몰이지만, 실제 목적은 채널톡이 고객을 식별하고 상담 맥락을 붙이는 과정을 보여주는 것이다.

## 핵심 데모 흐름

1. 방문자가 홈 화면에 들어온다.
2. 상품 목록과 상품 상세를 둘러본다.
3. 로그인하지 않은 상태에서 채널톡 버튼을 확인한다.
4. 회원가입 또는 로그인을 한다.
5. 같은 상품 상세 화면으로 돌아온다.
6. 장바구니에 상품을 담는다.
7. 마이페이지에서 가입일, 최근 본 상품, 장바구니, 주문 이력을 확인한다.
8. 디버그 패널에서 채널톡에 넘기는 `memberId`, 이름, 이메일, 고객 속성을 확인한다.
9. 면접에서 이 값을 상담원 화면의 고객 프로필과 상담 이력 연결로 설명한다.

## 사용자 관점의 화면

- 홈: 스킨케어 브랜드의 첫 화면이다. 베스트 상품과 카테고리 진입점이 보인다.
- 상품 목록: 고객이 여러 상품을 훑어보는 화면이다.
- 상품 상세: 고객이 상담을 시작하기 가장 자연스러운 화면이다. 현재 보고 있는 상품 정보를 채널톡 상담 맥락으로 설명할 수 있다.
- 회원가입/로그인: 익명 방문자가 우리 쇼핑몰의 회원으로 바뀌는 화면이다.
- 마이페이지: 고객 본인에게 보이는 프로필 화면이다. 채널톡 상담원에게도 일부 정보가 고객 프로필로 표시될 수 있다는 점을 설명한다.
- 장바구니: 고객의 구매 의도가 드러나는 화면이다. 실제 결제는 하지 않는다.
- 디버그 패널: 개발자가 채널톡에 어떤 이름표를 붙여 보내는지 확인하는 화면이다.

## 데이터 모델 초안

```text
users
- id
- name
- email
- password_digest
- customer_tier
- skin_type
- created_at
- updated_at

products
- id
- name
- slug
- category
- description
- price_cents
- image_url
- skin_type
- created_at
- updated_at

product_views
- id
- user_id
- product_id
- viewed_at

cart_items
- id
- user_id
- product_id
- quantity
- created_at
- updated_at

orders
- id
- user_id
- status
- total_cents
- placed_at
- created_at
- updated_at

order_items
- id
- order_id
- product_id
- quantity
- price_cents
- created_at
- updated_at
```

## 채널톡 설명 포인트

- 로그인 전 방문자는 쇼핑몰이 아직 이름을 모르는 고객이다. 채널톡에서는 익명 고객 흐름을 설명할 수 있다.
- 이메일을 남기거나 상담을 시작하면 `Lead` 관점으로 설명할 수 있다. 이 프로젝트에서는 실제 Lead 전환을 깊게 구현하지 않고 개념 설명 대상으로 둔다.
- 로그인 후에는 쇼핑몰의 `users.id`를 기반으로 안정적인 `memberId`를 만든다. 이 값은 같은 고객의 상담 이력을 묶는 핵심 키다.
- `name`, `email`, `created_at`, `customer_tier`, `last_viewed_product`, `cart_total` 같은 값은 상담원이 고객을 이해하는 데 쓰이는 속성이다.

## 기술 선택

- Ruby on Rails
- SQLite
- Rails 네이티브 인증
- ERB 또는 Rails 기본 뷰
- 최소한의 CSS
- 채널톡 Web SDK

## 성공 기준

- 로컬에서 앱을 실행하고 데모 흐름을 5분 안에 보여줄 수 있다.
- 로그인 전과 로그인 후의 채널톡 식별 차이를 설명할 수 있다.
- 디버그 패널에서 채널톡에 넘기는 값을 확인할 수 있다.
- README만 보고도 면접관 또는 본인이 실행 방법과 데모 시나리오를 따라갈 수 있다.

