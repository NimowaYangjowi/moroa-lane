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

- 긴 설명 대신 실제 값, payload, DB 레코드가 중심인가?
- `memberId`와 `userId`가 분리되어 보이는가?
- User API 조회와 S2S Event API 전송 순서가 화면에서 보이는가?
- 외부 API 실패가 숨겨지지 않는가?
- live update가 과도한 API 호출이나 비용을 만들지 않는가?
- 기존 `/debug/channel` SDK payload 화면과 역할이 겹치지 않는가?
- 작은 화면에서 JSON과 DB 레코드가 겹치지 않는가?
- README 또는 phase 문서가 실제 구현과 어긋나지 않는가?
