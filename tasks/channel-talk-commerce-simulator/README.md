# ChannelTalk Commerce Simulator Plan

이 폴더는 채널톡 Technical Project Management (US) 기술면접 준비용 시뮬레이션 프로젝트의 실행 계획을 담는다.

목표는 완성형 커머스 서비스를 만드는 것이 아니라, 작은 Rails 커머스 사이트에서 채널톡이 고객을 어떻게 식별하고 상담 맥락을 어떻게 붙이는지 설명할 수 있는 데모를 만드는 것이다.

## 프로젝트 한 줄 설명

Rails + SQLite로 만든 스킨케어 커머스 시뮬레이터에서 방문자가 상품을 둘러보다가 채팅을 시작하고, 회원가입/로그인 후에는 채널톡이 같은 고객을 `Member`로 식별하며 이름, 이메일, 가입일, 최근 본 상품, 장바구니, 주문 이력 같은 정보를 상담 맥락으로 받는 흐름을 구현한다.

## 면접에서 보여줄 핵심

- `Anonymous`, `Lead`, `Member`가 실제 서비스 화면에서 어떻게 달라지는지 설명한다.
- 커머스 회원의 `id`를 채널톡 `memberId`로 넘기는 이유를 설명한다.
- 고객 정보가 상담원 화면에 표시되려면 프론트 SDK와 서버 데이터가 어떤 순서로 연결되는지 설명한다.
- 개발팀이 연동 중 문제를 겪을 때 어떤 값부터 확인해야 하는지 보여준다.
- 프로젝트 `README.md`에 실행 방법, 데모 시나리오, 채널톡 연동 포인트를 정리한다.

## 포함 범위

- Rails 애플리케이션 생성
- SQLite 데이터베이스 사용
- Rails 네이티브 방식의 회원가입, 로그인, 로그아웃
- 상품 목록, 상품 상세, 홈 화면
- 최근 본 상품 기록
- 장바구니 담기, 수량 변경, 삭제
- 실제 결제 없는 가짜 주문 내역
- 마이페이지의 고객 프로필, 장바구니, 주문 이력 표시
- 채널톡 SDK 설치
- 로그인 전/후 채널톡 boot 또는 update 흐름 정리
- 현재 채널톡에 넘기는 고객 속성을 확인하는 디버그 패널
- 기술면접용 `README.md` 작성

## 제외 범위

- 실제 결제 연동
- 배송사 연동
- 관리자 상품 등록 화면
- 재고 관리
- 쿠폰, 포인트, 리뷰 작성
- 복잡한 검색/필터
- Channel Open API 전체 구현
- 프로덕션 배포

## 문서 구조

- [00-project-brief.md](./00-project-brief.md): 프로젝트 목적, 데모 사용자 흐름, 데이터 모델 초안
- [01-phase-setup.md](./01-phase-setup.md): Rails 앱 생성, 기본 설정, README 초안
- [02-phase-commerce-core.md](./02-phase-commerce-core.md): 상품 조회, 상품 상세, 최근 본 상품
- [03-phase-auth-customer-profile.md](./03-phase-auth-customer-profile.md): 회원가입/로그인, 마이페이지, 고객 속성
- [04-phase-cart-orders.md](./04-phase-cart-orders.md): 장바구니, 가짜 주문 이력
- [05-phase-channel-sdk.md](./05-phase-channel-sdk.md): 채널톡 SDK, 고객 식별, 디버그 패널
- [06-phase-demo-polish.md](./06-phase-demo-polish.md): 면접 데모 흐름, README 완성, 회귀 점검
- [review-template.md](./review-template.md): phase 종료 리뷰 템플릿
- [completion-log.md](./completion-log.md): 완료한 phase와 변경된 계획 기록

## 공통 진행 규칙

각 phase는 작은 완성 단위로 진행한다. phase가 끝날 때마다 다음 순서를 지킨다.

1. 해당 phase의 기능을 구현한다.
2. 테스트 또는 수동 확인으로 동작을 검증한다.
3. 회귀 위험과 개선사항을 리뷰한다.
4. `completion-log.md`에 완료 내용, 검증 결과, 남은 위험을 업데이트한다.
5. 구현 중 배운 내용 때문에 이후 계획이 달라져야 하면 남은 phase 문서를 업데이트한다.
6. phase 단위로 커밋한다.

## 권장 커밋 단위

- `phase 1: initialize rails interview simulator`
- `phase 2: add product browsing flow`
- `phase 3: add native auth and customer profile`
- `phase 4: add cart and seeded order history`
- `phase 5: add channel sdk identity context`
- `phase 6: polish interview demo and docs`

