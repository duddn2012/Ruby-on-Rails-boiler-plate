# MCP 서버 설정
module McpConfig
  # 서버 기본 설정
  SERVER_PORT = 3001
  SERVER_HOST = '0.0.0.0'
  
  # API 서버 설정
  API_BASE_URL = ENV['API_BASE_URL'] || 'http://localhost:3000/api'
  
  # 로깅 설정
  LOG_LEVEL = ENV['LOG_LEVEL'] || 'info'
  
  # CORS 설정
  CORS_ORIGINS = ['*']
  
  # 타임아웃 설정
  REQUEST_TIMEOUT = 30
  
  # 추천 알고리즘 가중치
  RECOMMENDATION_WEIGHTS = {
    skin_type: 0.4,      # 40%
    concerns: 0.3,       # 30%
    age_group: 0.2,      # 20%
    price_range: 0.1     # 10%
  }
  
  # 피부타입별 추천 카테고리
  SKIN_TYPE_CATEGORIES = {
    'dry' => ['moisturizer', 'cream', 'oil', 'serum'],
    'oily' => ['cleanser', 'toner', 'gel', 'essence'],
    'combination' => ['moisturizer', 'serum', 'essence'],
    'sensitive' => ['gentle', 'hypoallergenic', 'fragrance_free']
  }
  
  # 고민사항별 추천 성분
  CONCERN_INGREDIENTS = {
    'acne' => ['salicylic_acid', 'benzoyl_peroxide', 'niacinamide', 'zinc'],
    'aging' => ['retinol', 'vitamin_c', 'peptide', 'hyaluronic_acid'],
    'brightening' => ['vitamin_c', 'niacinamide', 'alpha_arbutin', 'kojic_acid'],
    'hydration' => ['hyaluronic_acid', 'glycerin', 'ceramide', 'squalane']
  }
end 