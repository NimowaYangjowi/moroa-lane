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

- 구매 완료 흐름이 기존 상품 조회, 로그인, 장바구니 흐름을 깨지 않는가?
- 내부 `purchase` 이벤트와 채널톡 delivery 상태가 분리되어 있는가?
- 외부 API 실패가 조용히 무시되지 않고 원인과 재시도 상태로 남는가?
- `memberId -> channel userId` 매핑의 원천과 갱신 시점이 명확한가?
- 중복 전송을 막는 제약이 있는가?
- delivery의 `pending -> processing -> sent/failed` 상태 전환이 동시 실행에 안전한가?
- 테스트가 실제 채널톡 API 네트워크에 의존하지 않는가?
- README 또는 phase 문서가 실제 구현과 어긋나지 않는가?
- 다음 phase에서 더 나은 구현 순서가 보이면 계획을 고쳤는가?
