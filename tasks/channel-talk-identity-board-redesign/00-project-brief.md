# Project Brief: ChannelTalk Identity Board Redesign

## 배경

`/debug/channel/identity-flow`는 면접 발표용 라이브 보드다. 핵심 질문은 "`memberId`와 채널톡 `userId`는 왜 다르고, 서버 S2S 이벤트는 왜 `userId`로 보내는가"이고, 이 보드는 그 답을 말 대신 실제 값으로 보여주려 한다.

현재 구현은 데이터는 다 있으나 시각 전달이 약하다. 아래 문제를 리디자인으로 해결한다.

## 현행 문제 (실제 렌더 기준)

1. **"Flowchart"가 flowchart가 아니다.** 6단계가 3열×2행 그리드(01 02 03 / 04 05 06)로 놓여 화살표도 방향도 없다. 시선이 우측 끝에서 좌측 아래로 꺾인다. 핵심 변환(`memberId` 입력 → `userId` 출력)이 어디에도 표현되지 않는다.
2. **flow / API / payload / DB가 서로 끊겨 있다.** 독립된 네모 상자들이라 연결이 발표자 멘트에 의존한다.
3. **첫인상이 빨강 FAILED + "KEY MISSING / SECRET MISSING"이다.** 자격증명 미설정(로컬 정상)이 "고장"처럼 보인다.
4. **비슷한 카드 두 줄(identity summary + counters)이 한 덩어리로 뭉친다.** "누구인가"와 "몇 건인가"의 위계가 사라진다.
5. **핵심 대비(`memberId` ↔ `userId`)가 안 살아난다.** UUID가 화면을 지배하고, 상대편 `not synced`는 같은 무게로 밋밋하다.
6. **색으로 의미를 안 쓴다.** 전부 크림/흰 카드라 input/output, 서버/클라이언트, 성공/대기/실패 구분이 없다.
7. **변화 피드백이 없다.** polling/클릭으로 값이 조용히 교체될 뿐 모션이 없어 "값이 움직인다"가 안 보인다.
8. **자잘한 문제.** Refresh 버튼 줄바꿈, raw ISO 타임스탬프 노출, 하단 DB 5열이 빽빽하고 핵심 `channel_user_mappings`가 강조되지 않음.

## 새 정보 구조

### 상단: 액션 + 상태 프레이밍

- 제목 + 발표 순서가 드러나는 단계형 버튼: `① Create purchase` → `② Send to ChannelTalk`, `Refresh`는 보조.
- 자격증명 미설정 시 "demo · credentials not set" 중립 표기. 실제 전송 실패만 빨강.

### 정체성 변환 (A: identity bridge)

identity summary 4칸을 하나의 변환 카드로 교체한다.

```
  memberId                                   userId
  shop_user_59b7ec7b…   ──GET @memberId──►    not synced yet
  input · Acme가 만든 키                       output · 채널톡이 발급
```

- 두 값을 화살표 양끝에 배치, 화살표 위에 변환을 일으키는 API 동작을 얹는다.
- `memberId`는 input 색, `userId`는 output 색으로 고정한다. 면접 핵심 질문에 한 눈에 답한다.

### 중앙: 연결형 가로 레일 flowchart (B)

```
Acme user → memberId → User API(GET @memberId) → Mapping DB(userId) → S2S Purchase(POST userId) → Delivery[칩]
```

- 단계 사이를 화살표로 잇고 시선이 좌→우로 흐르게 한다.
- `memberId`를 쓰는 단계는 input 색 보더, `userId`를 쓰는 단계는 output 색 보더로 묶어 "여기서 키가 바뀐다"가 위치+색으로 드러나게 한다.
- 좁은 화면에서는 세로 레일로 접되 화살표는 유지한다.

### 단계 ↔ 아티팩트 연결 (C)

- User API 단계 → `GET /open/v5/users/@{memberId}` 경로.
- S2S Purchase 단계 → `POST /open/v5/users/{userId}/events` 경로 + payload JSON.
- Delivery 단계 → status / attempts / last_error.
- payload 패널에 "server-generated · not browser SDK" 배지를 명시한다.

### 하단: DB record 위계화 (F)

- 스토리 핵심 3개(`channel_user_mappings`, `events`, `channel_event_deliveries`)를 위/강조.
- `users`, `orders`는 보조.
- `channel_user_mappings` 행은 `member_id`와 `channel_user_id`를 나란히 강조한다.

### 변화 하이라이트 (E)

- polling/클릭으로 값이 바뀐 카운터·DB 셀·상태 칩에 약 0.6초 배경 펄스.
- 순수 client-side 비교로 처리하고 추가 API 호출은 만들지 않는다.

## 시각 토큰 기준 (3계층)

| 역할(semantic) | 의미 | primitive 후보 |
| --- | --- | --- |
| identity-input | `memberId`, Acme가 만든 키를 쓰는 단계 | teal 계열 보더/배경 |
| identity-output | `userId`, 채널톡이 발급한 키를 쓰는 단계 | amber/gold 계열 보더/배경 |
| server-trusted | 서버가 만든 S2S payload 표면 | 기존 dark `#1d1b18` 유지 |
| state-success (`sent`/`synced`) | 정상 전송/동기화 | 기존 green 칩 유지 |
| state-pending (`processing`/`waiting`) | 진행 중 | 기존 amber 칩 유지 |
| state-failure (`failed`) | 실제 전송 실패 | 기존 red 칩 유지 |
| state-not-configured | 자격증명 미설정으로 막힌 상태 | 중립 회색 칩 (신규) |

기존 `application.css`의 cream(`#f7f3ee`) / tan border(`#e6ddd2`) / teal label(`#2f6f68`) 팔레트를 base로 유지하고, input/output/not-configured 역할 토큰만 추가한다. 새 색은 역할에만 쓰고 장식으로 쓰지 않는다.

## 제외 범위

- 차트 라이브러리 도입.
- 실제 채널톡 Open API 호출/delivery job 로직 변경.
- 데모 보드 밖 화면 변경.
- 운영 대시보드용 집계·페이지네이션.
