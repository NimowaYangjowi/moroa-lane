# Phase Review Template

phase가 끝날 때마다 아래 형식으로 `completion-log.md`에 기록한다.

```md
## Phase N: 제목

완료일:
커밋:

### 완료한 것

-

### 검증한 것

-

### 회귀 위험

-

### 개선사항

-

### 다음 phase 계획 변경

- 변경 없음
```

## 리뷰 기준

- `memberId → userId` 변환이 색+화살표로 한 눈에 읽히는가?
- 6단계 flow가 방향 있는 한 줄(또는 세로) 레일로 연결돼 보이는가?
- 각 단계가 자기 API 경로/payload/delivery 결과와 시각적으로 묶이는가?
- 자격증명 미설정이 중립 상태로, 실제 실패가 빨강으로 분리돼 보이는가? (실패를 숨기지 않는가?)
- 색이 의미 역할(input/output/server/success/pending/failure/not-configured)에만 쓰이는가?
- 클릭/polling 변화가 펄스로 보이고, `prefers-reduced-motion`을 존중하는가?
- live update가 추가 API 호출이나 count query를 만들지 않는가?
- 작은 화면에서 레일이 접히고 JSON/DB가 겹치지 않는가?
- 기존 `/debug/channel` SDK payload 화면과 역할이 겹치지 않는가?
- README 또는 phase 문서가 실제 구현과 어긋나지 않는가?
