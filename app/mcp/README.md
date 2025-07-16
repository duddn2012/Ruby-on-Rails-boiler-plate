# 🎨 내 화장품을 찾아줘! MCP 서버

Cursor에서 Agent로서 동작하는 AI 기반 화장품 추천 MCP (Model Context Protocol) 서버입니다.

## 📋 개요

이 MCP 서버는 Cursor AI 어시스턴트가 화장품 추천 API와 상호작용할 수 있도록 하는 도구들을 제공합니다. MCP 프로토콜을 준수하여 Cursor에서 직접 호출할 수 있습니다.

## 🚀 시작하기

### 1. 의존성 설치
```bash
bundle install
```

### 2. Rails 서버 실행
```bash
rails server
```

### 3. MCP 서버 실행
```bash
ruby bin/mcp_server
```

### 4. MCP 서버 테스트
```bash
ruby bin/test_mcp_interactive.rb
```

## 🔧 Cursor에서 MCP 서버 연결

### 1. Cursor 설정 파일 생성
Cursor 설정 디렉토리에 `settings.json` 파일을 생성하거나 수정:

```json
{
  "mcpServers": {
    "cosmetic-recommendation": {
      "command": "ruby",
      "args": ["/path/to/your/project/bin/mcp_server"],
      "env": {
        "API_BASE_URL": "http://localhost:3000/api"
      }
    }
  }
}
```

### 2. Cursor 재시작
Cursor를 재시작하면 MCP 서버가 연결됩니다.

## 🔧 사용 가능한 도구들

### 사용자 관리
- **`register_user_skin_info`** - 사용자의 피부 정보 등록
- **`get_user_profile`** - 사용자 프로필 조회
- **`update_user_profile`** - 사용자 프로필 업데이트

### 추천 시스템
- **`get_cosmetic_recommendations`** - 개인화된 화장품 추천
- **`get_products_by_ingredient`** - 특정 성분이 포함된 제품 검색

### 제품 검색
- **`search_products`** - 제품 검색
- **`search_ingredients`** - 성분 검색

## 📊 MCP 프로토콜

### 서버 정보
- **URL**: `http://localhost:3001`
- **프로토콜**: JSON-RPC 2.0
- **Content-Type**: `application/json`

### 주요 메서드
- `tools/list` - 사용 가능한 도구 목록 조회
- `tools/call` - 도구 실행

### 요청 예제
```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "tools/call",
  "params": {
    "name": "register_user_skin_info",
    "arguments": {
      "skin_type": "combination",
      "concerns": "acne,hydration",
      "age_group": "twenties"
    }
  }
}
```

### 응답 예제
```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "content": [
      {
        "type": "text",
        "text": "{\"success\":true,\"message\":\"사용자 피부 정보가 성공적으로 등록되었습니다\",\"user\":{\"id\":1,\"skin_type\":\"combination\",\"concerns\":\"acne,hydration\",\"age_group\":\"twenties\"}}"
      }
    ]
  }
}
```

## 🧪 테스트

### 대화형 테스트
```bash
ruby bin/test_mcp_interactive.rb
```

### curl을 이용한 테스트
```bash
# 도구 목록 조회
curl -X POST http://localhost:3001 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list","params":{}}'

# 사용자 등록
curl -X POST http://localhost:3001 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"register_user_skin_info","arguments":{"skin_type":"combination","concerns":"acne,hydration","age_group":"twenties"}}}'
```

## 📊 추천 알고리즘

### 가중치 시스템
- **피부타입 매칭**: 40%
- **고민사항 매칭**: 30%
- **연령대 매칭**: 20%
- **가격대 매칭**: 10%

### 피부타입별 추천 카테고리
- **건성**: moisturizer, cream, oil, serum
- **지성**: cleanser, toner, gel, essence
- **복합성**: moisturizer, serum, essence
- **민감성**: gentle, hypoallergenic, fragrance_free

### 고민사항별 추천 성분
- **여드름**: salicylic_acid, benzoyl_peroxide, niacinamide, zinc
- **노화**: retinol, vitamin_c, peptide, hyaluronic_acid
- **미백**: vitamin_c, niacinamide, alpha_arbutin, kojic_acid
- **보습**: hyaluronic_acid, glycerin, ceramide, squalane

## 🔌 API 엔드포인트

### 기본 URL
```
http://localhost:3000/api
```

### 주요 엔드포인트
- `POST /users` - 사용자 등록
- `GET /users/:id` - 사용자 조회
- `PATCH /users/:id` - 사용자 업데이트
- `POST /recommendations/generate` - 추천 생성
- `POST /recommendations/by_ingredient` - 성분별 추천
- `GET /products/search` - 제품 검색
- `GET /ingredients/search` - 성분 검색

## 🧪 테스트 예제

### 사용자 등록
```ruby
result = client.call_tool("register_user_skin_info", {
  "skin_type" => "combination",
  "concerns" => "acne,hydration",
  "age_group" => "twenties"
})
```

### 제품 검색
```ruby
result = client.call_tool("search_products", {
  "query" => "moisturizer",
  "category" => "cream",
  "max_price" => 50000
})
```

### 추천 생성
```ruby
result = client.call_tool("get_cosmetic_recommendations", {
  "user_id" => 1
})
```

## 📝 응답 형식

### 성공 응답
```json
{
  "success": true,
  "message": "작업이 성공적으로 완료되었습니다",
  "data": { ... }
}
```

### 오류 응답
```json
{
  "success": false,
  "error": "오류 메시지"
}
```

## 🔧 설정

### 환경 변수
- `API_BASE_URL`: API 서버 기본 URL (기본값: http://localhost:3000/api)
- `LOG_LEVEL`: 로그 레벨 (기본값: info)

### 설정 파일
- `app/mcp/config.rb`: MCP 서버 설정

## 🚀 배포

### Heroku 배포
```bash
# 환경 변수 설정
heroku config:set API_BASE_URL=https://your-app.herokuapp.com/api

# 배포
git push heroku main
```

### Docker 배포
```bash
# Docker 이미지 빌드
docker build -t cosmetic-mcp-server .

# 컨테이너 실행
docker run -p 3001:3001 cosmetic-mcp-server
```

## 📚 참고 자료

- [MCP Protocol](https://modelcontextprotocol.io/)
- [Ruby on Rails](https://rubyonrails.org/)
- [Sinatra](http://sinatrarb.com/)
- [API Documentation](https://guides.rubyonrails.org/api_app.html)

## 🤝 기여하기

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## �� 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 