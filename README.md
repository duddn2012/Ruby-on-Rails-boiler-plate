
# 내 화장품을 찾아줘!

## 개요

사용자의 피부 상태와 고민사항을 분석하여 최적의 화장품을 추천해주는 AI 기반 서비스입니다.

### 주요 기능

- **개인 맞춤형 화장품 추천**: 피부타입, 고민사항, 연령대를 고려한 맞춤 추천
- **성분 기반 분석**: 화장품 성분의 효과와 안전성을 데이터로 분석
- **AI 어시스턴트 연동**: MCP 서버를 통한 자연어 기반 상담 서비스

## 🏗 시스템 아키텍처

사용자 → AI 어시스턴트 → Rails 앱 (API + MCP 서버) → Database


### 기술 스택

- **Backend**: Ruby on Rails
- **Database**: SQLite (개발) / PostgreSQL (운영)
- **AI 연동**: MCP (Model Context Protocol) 서버
- **배포**: Heroku

## 📊 데이터 모델

### User (사용자)

- skin_type: 피부타입 (건성/지성/복합성)
- concerns: 고민사항 (여드름/주름/미백 등)
- age_group: 연령대

### Product (화장품)

- name, brand, category, ingredients, effects, price_range

### Recommendation (추천)

- user_id, product_id, score: 매칭 점수

## 🤖 MCP 서버 구현

### 프로젝트 구조

app/
├── controllers/          # 기존 API 컨트롤러
├── models/              # 기존 모델
├── mcp/                 # MCP 서버 (새로 추가)
│   ├── server.rb        # MCP 서버 메인 클래스
│   ├── tools/           # MCP 도구들
│   └── schemas/         # 스키마 정의
└── views/               # 기존 뷰


### MCP 도구

- register_user_skin_info: 사용자 피부 정보 등록
- get_cosmetic_recommendations: 화장품 추천 요청
- get_product_details: 제품 상세 정보 조회

## 🔄 추천 알고리즘

### 기본 추천 로직

1. 사용자 피부타입과 고민사항 분석
2. 성분 데이터베이스에서 적합한 성분 찾기
3. 해당 성분이 포함된 제품들 필터링
4. 가격대, 브랜드 선호도 고려하여 순위 결정

### 매칭 점수 계산

- 피부타입 매칭: 40점
- 고민사항 매칭: 30점
- 연령대 매칭: 20점
- 가격대 매칭: 10점

## 🎨 AI 어시스턴트 연동

### 사용 예시

사용자: "건성 피부인데 주름이 많이 생기고 있어요. 추천해주세요."

AI 어시스턴트 → MCP 서버:
1. register_user_skin_info 호출
2. get_cosmetic_recommendations 호출
3. 결과를 자연어로 변환하여 응답


### 자연어 명령어 예시

- "건성 피부에 좋은 세럼 추천해줘"
- "여드름성 피부용 토너 찾아줘"
- "30대 여성용 안티에이징 크림 추천"
- "추천받은 제품의 성분 분석해줘"

## 🚀 개발 및 배포

### 개발 환경 설정

bash
bundle install
rails db:create db:migrate db:seed
rails server


### MCP 서버 실행

bash
rails mcp:server:start
# 또는
ruby app/mcp/server.rb


### 환경 설정

ruby
# config/mcp_server.yml
development:
  port: 3001
  host: "localhost"
  api_base_url: "<http://localhost:3000/api>"


### Heroku 배포

bash
git push heroku main
heroku ps:scale mcp=1


## 📋 API 엔드포인트

### 사용자 관리

- POST /api/users - 사용자 피부 정보 등록
- GET /api/users/:id - 사용자 정보 조회

### 제품 관리

- GET /api/products - 화장품 목록 조회
- GET /api/products/:id - 제품 상세 정보

### 추천 시스템

- POST /api/recommendations - 화장품 추천 요청
- GET /api/recommendations/:user_id - 사용자별 추천 결과 조회

이제 AI 어시스턴트가 MCP 서버를 통해 지능적인 화장품 추천 서비스를 제공할 수 있습니다!