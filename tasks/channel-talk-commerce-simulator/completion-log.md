# Completion Log

이 문서는 phase가 끝날 때마다 업데이트한다. 단순히 완료 여부만 적지 말고, 무엇을 검증했고 어떤 회귀 위험이 남았는지 같이 기록한다.

## Phase 0: Planning Documents

완료일: 2026-05-29
커밋: f789905, e7c4207

### 완료한 것

- 채널톡 기술면접용 커머스 시뮬레이션 프로젝트의 범위를 정했다.
- `tasks/channel-talk-commerce-simulator/` 아래에 전체 계획과 phase 문서를 작성했다.
- 각 phase 문서 상단에 커밋, 리뷰, 완료 로그, 남은 계획 업데이트 지시사항을 넣었다.
- 프로젝트 `README.md` 작성도 구현 범위에 포함했다.
- 실제 DTC 커머스 사이트처럼 보이는 예제 사이트를 목표로 한다는 기준을 문서에 보강했다.

### 검증한 것

- 문서 기준으로 phase별 구현 순서가 이어지는지 확인했다.
- 결제, 배송, 관리자 기능, 복잡한 검색/필터는 제외 범위로 명시했다.

### 회귀 위험

- 아직 실제 Rails 앱이 없으므로 기술 선택은 구현 중 조정될 수 있다.
- 채널톡 SDK의 최신 호출 방식은 구현 phase에서 공식 문서를 다시 확인해야 한다.

### 개선사항

- Rails 버전과 인증 방식이 정해지면 Phase 1 문서에 구체 명령을 추가한다.
- 실제 채널톡 계정에서 확인한 plugin key 설정 방식은 Phase 5 문서에 반영한다.

### 다음 phase 계획 변경

- 변경 없음

## Phase 5: Channel SDK

완료일: 2026-05-29
커밋: 08747fc

### 완료한 것

- 공식 ChannelTalk Web SDK 문서를 확인하고 MPA 방식의 SDK boot 스크립트를 레이아웃에 추가했다.
- `CHANNELTALK_PLUGIN_KEY`가 있으면 실제 SDK를 boot하고, 없으면 로컬 데모 버튼을 보여주게 했다.
- `ChannelPayload` 객체로 익명 방문자와 로그인 회원의 boot payload를 분리했다.
- 로그인 회원 payload에 `memberId`, 이름, 이메일, 가입일, 고객 등급, 피부 타입, 최근 본 상품, 장바구니 수량, 장바구니 합계, 최근 주문일을 포함했다.
- `CHANNELTALK_MEMBER_HASH_SECRET`이 있으면 `memberHash`를 포함하도록 했다.
- `/debug/channel` 디버그 패널을 추가했다.

### 검증한 것

- `bin/rails test` 통과.
- plugin key가 없어도 앱이 깨지지 않고 로컬 데모 버튼이 표시되는 구조를 확인했다.

### 회귀 위험

- 실제 ChannelTalk plugin key로는 아직 브라우저 실검증을 하지 않았다.
- custom profile field 이름은 데모 설명용으로 정했다. 실제 고객사 도입 시 필드 네이밍은 채널톡 운영 정책에 맞춰 조정해야 한다.

### 개선사항

- Phase 6에서 README에 `CHANNELTALK_PLUGIN_KEY`, `CHANNELTALK_MEMBER_HASH_SECRET` 설정 방법을 적는다.
- Phase 6에서 공식 문서 기준으로 `memberId`와 member hash 주의사항을 면접용 설명에 추가한다.

### 다음 phase 계획 변경

- 변경 없음

## Phase 4: Cart And Orders

완료일: 2026-05-29
커밋: 35a8d3a

### 완료한 것

- `CartItem`, `Order`, `OrderItem` 모델을 추가했다.
- 상품 상세에서 로그인한 사용자가 상품을 장바구니에 담을 수 있게 했다.
- 장바구니 화면에서 수량 변경과 삭제를 할 수 있게 했다.
- 마이페이지에 현재 장바구니 요약과 과거 주문 이력을 표시했다.
- seed에 데모 계정의 장바구니와 가짜 주문 이력을 추가했다.
- 실제 결제는 구현하지 않았고, 장바구니 요약에도 제외 범위로 표시했다.

### 검증한 것

- `bin/rails db:migrate db:seed` 성공.
- `bin/rails test` 통과.

### 회귀 위험

- 장바구니는 로그인 사용자만 지원한다. 비로그인 장바구니는 면접 범위에서 제외했다.
- 주문은 seed 기반 더미 데이터다. 실제 주문 생성 플로우는 없다.

### 개선사항

- Phase 5에서 `cart_items_count`, `cart_total`, `last_order_at`을 채널톡 디버그 payload에 포함한다.
- Phase 6에서 결제를 구현하지 않은 이유를 README에 더 명확히 적는다.

### 다음 phase 계획 변경

- 변경 없음

## Phase 2: Commerce Core

완료일: 2026-05-29
커밋: 0fa229b

### 완료한 것

- `Product` 모델과 slug 기반 상품 URL을 추가했다.
- 스킨케어 상품 seed 데이터를 추가했다.
- 홈 화면에 베스트셀러 상품 카드 영역을 추가했다.
- 상품 목록과 상품 상세 화면을 만들었다.
- 상품 상세 진입 시 세션에 최근 본 상품 slug를 저장하도록 했다.
- 상품 관련 화면이 실제 커머스 예제 사이트처럼 보이도록 카드, 이미지, 가격, 상세 레이아웃 CSS를 추가했다.

### 검증한 것

- `bin/rails db:migrate db:seed` 성공.
- `bin/rails test` 통과.

### 회귀 위험

- 최근 본 상품은 아직 세션 기반이라 로그인 사용자와 DB로 연결되지 않는다.
- 상품 이미지는 외부 Unsplash URL이라 네트워크 상태에 따라 로딩이 느릴 수 있다.

### 개선사항

- Phase 3에서 로그인 사용자의 최근 본 상품을 DB 모델로 연결할지 결정한다.
- Phase 4에서 상품 상세의 임시 `Add to cart soon` 버튼을 실제 장바구니 액션으로 바꾼다.

### 다음 phase 계획 변경

- `ProductView`는 Phase 3에서 `User` 모델이 생긴 뒤 생성하는 방향으로 조정한다.

## Phase 3: Auth And Customer Profile

완료일: 2026-05-29
커밋: e59a758

### 완료한 것

- Rails 기본 인증 생성기를 적용했다.
- 회원가입 화면과 `RegistrationsController`를 추가했다.
- `User`에 이름, 이메일, 고객 등급, 피부 타입, `memberId` 메서드를 추가했다.
- 로그인/로그아웃 내비게이션을 추가했다.
- 마이페이지에서 고객 프로필과 최근 본 상품을 보여주도록 했다.
- 로그인한 고객이 상품 상세를 보면 `ProductView`로 조회 이력이 저장되게 했다.
- 데모 계정 `jiwoo@example.com / password123`을 seed에 추가했다.

### 검증한 것

- `bin/rails db:migrate db:seed` 성공.
- `bin/rails test` 통과.

### 회귀 위험

- Rails 인증 생성기가 만든 비밀번호 재설정 화면은 아직 기본 UI에 가깝다.
- 최근 본 상품은 상품 상세에 들어갈 때마다 기록되므로 중복 조회 기록이 쌓일 수 있다.

### 개선사항

- Phase 4에서 마이페이지에 장바구니와 주문 이력을 붙인다.
- Phase 5에서 `current_user.member_id`, 이름, 이메일, 가입일, 최근 본 상품을 채널톡 payload로 노출한다.

### 다음 phase 계획 변경

- 변경 없음

## Phase 1: Setup

완료일: 2026-05-29
커밋: 6986599

### 완료한 것

- Ruby 3.3.6을 프로젝트 `.ruby-version`으로 고정했다.
- Rails 8.1 앱을 생성했다.
- 홈 화면과 기본 레이아웃을 만들었다.
- 프로젝트 루트 `README.md` 초안을 채널톡 기술면접용 시뮬레이션 설명으로 교체했다.
- 첫 화면에서 실제 커머스 예제 사이트 방향이 드러나도록 히어로 영역을 추가했다.

### 검증한 것

- `bin/rails test` 통과.

### 회귀 위험

- 아직 상품, 인증, 장바구니가 없으므로 홈 화면의 링크는 최소 상태다.
- 실제 사이트처럼 보이는 완성도는 Phase 2 이후 상품 화면이 들어가야 판단할 수 있다.

### 개선사항

- Phase 2에서 홈의 `Shop` 링크를 실제 상품 목록으로 연결한다.
- 전체 내비게이션은 인증과 장바구니가 생긴 뒤 다시 정리한다.

### 다음 phase 계획 변경

- 변경 없음

## Phase 6: Demo Polish

완료일: 2026-05-29
커밋: Phase 6 최종 커밋

### 완료한 것

- 프로젝트 루트 `README.md`를 면접용 실행 문서로 완성했다.
- `.env.example`을 추가해 ChannelTalk plugin key와 member hash secret 설정값을 보여줬다.
- 포트 3000이 사용 중일 때 `-p 3001`로 실행하는 방법을 README에 추가했다.
- 홈, 상품 목록, 상품 상세, 로그인, 채널톡 디버그 페이지가 로컬 서버에서 200으로 열리는지 확인했다.

### 검증한 것

- `bin/rails test` 통과.
- `bin/rails server -p 3001` 실행 성공.
- `curl`로 `/`, `/products`, `/products/cloud-barrier-cream`, `/session/new`, `/debug/channel` 200 응답과 핵심 문구 렌더링을 확인했다.

### 회귀 위험

- Playwright가 로컬 Node 런타임에 없어 스크린샷 자동 검증은 하지 못했다.
- 실제 ChannelTalk plugin key를 넣은 실계정 boot 검증은 아직 하지 않았다.

### 개선사항

- 실제 면접 전 채널톡 무료 계정의 plugin key로 한 번 boot를 확인하면 좋다.
- 가능하면 Chrome 또는 Playwright 환경에서 모바일 폭 화면을 한 번 더 확인한다.

### 다음 phase 계획 변경

- 모든 계획 phase 완료.
