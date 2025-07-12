# Ruby on Rails Product API

이 프로젝트는 Ruby on Rails를 사용하여 구현된 Product(상품) 관리 API입니다.

## 📋 Product 모델 스키마

Product 모델은 다음과 같은 필드를 가지고 있습니다:

- `id` (Primary Key)
- `name` (String, 필수값)
- `description` (String)
- `price` (Integer)
- `created_at` (DateTime)
- `updated_at` (DateTime)

## 🚀 API 엔드포인트

### 1. 상품 목록 조회

```
GET /products
```

**응답 예시:**

```json
[
  {
    "id": 1,
    "name": "상품명",
    "description": "상품 설명",
    "price": 10000,
    "created_at": "2025-07-11T14:56:38.000Z",
    "updated_at": "2025-07-11T14:56:38.000Z"
  }
]
```

### 2. 특정 상품 조회

```
GET /products/:id
```

**응답 예시:**

```json
{
  "name": "상품명",
  "price": 10000,
  "created_at": "2025-07-11T14:56:38.000Z"
}
```

### 3. 새 상품 생성

```
POST /products
```

**요청 바디:**

```json
{
  "product": {
    "name": "상품명",
    "description": "상품 설명",
    "price": 10000
  }
}
```

**성공 응답 (201 Created):**

```json
{
  "id": 1,
  "name": "상품명",
  "description": "상품 설명",
  "price": 10000,
  "created_at": "2025-07-11T14:56:38.000Z",
  "updated_at": "2025-07-11T14:56:38.000Z"
}
```

**실패 응답 (422 Unprocessable Entity):**

```json
{
  "errors": ["Name can't be blank"]
}
```

### 4. 상품 생성 폼 (새 상품 페이지)

```
GET /products/new
```

## 🔧 기술 스택

- **Framework**: Ruby on Rails 8.0
- **Controller**: ActionController::API
- **Database**: SQLite (개발 환경)
- **Validation**: Active Record Validations

## 📁 주요 파일 구조

```
app/
├── controllers/
│   └── products_controller.rb    # Product API 컨트롤러
├── models/
│   └── product.rb                # Product 모델
├── services/
│   └── products_service.rb       # Product 비즈니스 로직
└── views/
    └── products/                 # Product 뷰 템플릿
        ├── index.html.erb
        ├── new.html.erb
        └── show.html.erb
```

## ⚠️ 주의사항

1. **필수 필드**: `name` 필드는 반드시 입력해야 합니다.
2. **API 컨트롤러**: `ActionController::API`를 상속받아 JSON 응답만 처리합니다.
3. **트랜잭션**: ProductsService에서 데이터베이스 트랜잭션을 사용합니다.

## 🚀 실행 방법

1. 의존성 설치:

```bash
bundle install
```

2. 데이터베이스 설정:

```bash
bin/rails db:create
bin/rails db:migrate
```

3. 서버 실행:

```bash
bin/rails server
```

서버는 기본적으로 `http://localhost:3000`에서 실행됩니다.
