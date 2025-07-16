# 시드 데이터 생성
puts "🌱 시드 데이터 생성을 시작합니다..."

# 기존 데이터 삭제
puts "🗑️ 기존 데이터 삭제 중..."
Recommendation.destroy_all
ProductIngredient.destroy_all
Product.destroy_all
Ingredient.destroy_all
User.destroy_all

# 1. 성분 데이터 생성
puts "🧪 성분 데이터 생성 중..."
ingredients_data = [
  # 보습 성분
  { name: "hyaluronic_acid", description: "강력한 보습 효과를 가진 성분", effect: "hydration", safety_level: "safe" },
  { name: "glycerin", description: "천연 보습제로 피부에 수분을 공급", effect: "hydration", safety_level: "safe" },
  { name: "ceramide", description: "피부 장벽을 강화하는 성분", effect: "hydration", safety_level: "safe" },
  { name: "squalane", description: "가벼운 보습 효과를 가진 오일", effect: "hydration", safety_level: "safe" },
  
  # 여드름 치료 성분
  { name: "salicylic_acid", description: "각질 제거 및 여드름 치료 성분", effect: "acne", safety_level: "moderate" },
  { name: "benzoyl_peroxide", description: "강력한 여드름 치료 성분", effect: "acne", safety_level: "moderate" },
  { name: "niacinamide", description: "여드름과 모공을 개선하는 성분", effect: "acne", safety_level: "safe" },
  { name: "zinc", description: "피부 진정 및 여드름 치료 성분", effect: "acne", safety_level: "safe" },
  
  # 노화 방지 성분
  { name: "retinol", description: "강력한 항노화 성분", effect: "aging", safety_level: "moderate" },
  { name: "vitamin_c", description: "항산화 및 미백 효과", effect: "aging", safety_level: "safe" },
  { name: "peptide", description: "주름 개선 및 피부 탄력 증진", effect: "aging", safety_level: "safe" },
  
  # 미백 성분
  { name: "alpha_arbutin", description: "자연스러운 미백 효과", effect: "brightening", safety_level: "safe" },
  { name: "kojic_acid", description: "강력한 미백 성분", effect: "brightening", safety_level: "moderate" }
]

ingredients = ingredients_data.map do |data|
  Ingredient.create!(data)
end

puts "✅ #{ingredients.length}개의 성분이 생성되었습니다."

# 2. 제품 데이터 생성
puts "🧴 제품 데이터 생성 중..."
products_data = [
  # 보습 제품
  { name: "하이알루론산 세럼", brand: "The Ordinary", category: "serum", price: 25000, description: "강력한 보습 효과를 가진 하이알루론산 세럼" },
  { name: "세라마이드 크림", brand: "CeraVe", category: "moisturizer", price: 35000, description: "피부 장벽을 강화하는 세라마이드 크림" },
  { name: "글리세린 토너", brand: "Innisfree", category: "toner", price: 15000, description: "천연 보습제가 함유된 토너" },
  { name: "스쿠알렌 오일", brand: "The Ordinary", category: "oil", price: 20000, description: "가벼운 보습 오일" },
  
  # 여드름 치료 제품
  { name: "살리실산 토너", brand: "Paula's Choice", category: "toner", price: 45000, description: "각질 제거 및 여드름 치료 토너" },
  { name: "벤조일 퍼옥사이드 젤", brand: "La Roche-Posay", category: "gel", price: 30000, description: "강력한 여드름 치료 젤" },
  { name: "나이아신아마이드 세럼", brand: "The Ordinary", category: "serum", price: 18000, description: "여드름과 모공 개선 세럼" },
  
  # 노화 방지 제품
  { name: "레티놀 크림", brand: "La Roche-Posay", category: "cream", price: 55000, description: "강력한 항노화 크림" },
  { name: "비타민C 세럼", brand: "Skinceuticals", category: "serum", price: 120000, description: "고농축 비타민C 세럼" },
  { name: "펩타이드 크림", brand: "The Ordinary", category: "cream", price: 28000, description: "주름 개선 펩타이드 크림" },
  
  # 미백 제품
  { name: "알파 아르부틴 세럼", brand: "The Ordinary", category: "serum", price: 22000, description: "자연스러운 미백 세럼" },
  { name: "코지산 크림", brand: "Some By Mi", category: "cream", price: 32000, description: "강력한 미백 크림" },
  
  # 클렌저
  { name: "젠틀 클렌저", brand: "CeraVe", category: "cleanser", price: 25000, description: "민감성 피부용 클렌저" },
  { name: "폼 클렌저", brand: "Innisfree", category: "cleanser", price: 18000, description: "거품이 풍부한 클렌저" },
  
  # 선크림
  { name: "선크림 SPF50", brand: "La Roche-Posay", category: "sunscreen", price: 40000, description: "강력한 자외선 차단 선크림" }
]

products = products_data.map do |data|
  Product.create!(data)
end

puts "✅ #{products.length}개의 제품이 생성되었습니다."

# 3. 제품-성분 연결
puts "🔗 제품-성분 연결 중..."
product_ingredient_connections = [
  # 하이알루론산 세럼
  { product: products.find { |p| p.name == "하이알루론산 세럼" }, ingredient: ingredients.find { |i| i.name == "hyaluronic_acid" } },
  
  # 세라마이드 크림
  { product: products.find { |p| p.name == "세라마이드 크림" }, ingredient: ingredients.find { |i| i.name == "ceramide" } },
  
  # 글리세린 토너
  { product: products.find { |p| p.name == "글리세린 토너" }, ingredient: ingredients.find { |i| i.name == "glycerin" } },
  
  # 스쿠알렌 오일
  { product: products.find { |p| p.name == "스쿠알렌 오일" }, ingredient: ingredients.find { |i| i.name == "squalane" } },
  
  # 살리실산 토너
  { product: products.find { |p| p.name == "살리실산 토너" }, ingredient: ingredients.find { |i| i.name == "salicylic_acid" } },
  
  # 벤조일 퍼옥사이드 젤
  { product: products.find { |p| p.name == "벤조일 퍼옥사이드 젤" }, ingredient: ingredients.find { |i| i.name == "benzoyl_peroxide" } },
  
  # 나이아신아마이드 세럼
  { product: products.find { |p| p.name == "나이아신아마이드 세럼" }, ingredient: ingredients.find { |i| i.name == "niacinamide" } },
  
  # 레티놀 크림
  { product: products.find { |p| p.name == "레티놀 크림" }, ingredient: ingredients.find { |i| i.name == "retinol" } },
  
  # 비타민C 세럼
  { product: products.find { |p| p.name == "비타민C 세럼" }, ingredient: ingredients.find { |i| i.name == "vitamin_c" } },
  
  # 펩타이드 크림
  { product: products.find { |p| p.name == "펩타이드 크림" }, ingredient: ingredients.find { |i| i.name == "peptide" } },
  
  # 알파 아르부틴 세럼
  { product: products.find { |p| p.name == "알파 아르부틴 세럼" }, ingredient: ingredients.find { |i| i.name == "alpha_arbutin" } },
  
  # 코지산 크림
  { product: products.find { |p| p.name == "코지산 크림" }, ingredient: ingredients.find { |i| i.name == "kojic_acid" } }
]

product_ingredient_connections.each do |connection|
  ProductIngredient.create!(connection)
end

puts "✅ 제품-성분 연결이 완료되었습니다."

# 4. 샘플 사용자 생성
puts "👤 샘플 사용자 생성 중..."
users_data = [
  { skin_type: "dry", concerns: "hydration,aging", age_group: "thirties" },
  { skin_type: "oily", concerns: "acne", age_group: "twenties" },
  { skin_type: "combination", concerns: "acne,hydration", age_group: "twenties" },
  { skin_type: "sensitive", concerns: "hydration", age_group: "forties_plus" },
  { skin_type: "dry", concerns: "aging,brightening", age_group: "forties_plus" }
]

users = users_data.map do |data|
  User.create!(data)
end

puts "✅ #{users.length}명의 샘플 사용자가 생성되었습니다."

# 5. 샘플 추천 생성
puts "🎯 샘플 추천 생성 중..."
users.each do |user|
  # 각 사용자에게 상위 3개 제품 추천
  top_products = products.first(3)
  
  top_products.each_with_index do |product, index|
    score = 85 - (index * 10) # 85, 75, 65 점수
    reason = "#{user.skin_type} 피부에 적합한 #{product.category} 제품"
    
    Recommendation.create!(
      user: user,
      product: product,
      score: score,
      reason: reason
    )
  end
end

puts "✅ 샘플 추천이 생성되었습니다."

puts "🎉 시드 데이터 생성이 완료되었습니다!"
puts "📊 생성된 데이터:"
puts "  - 성분: #{Ingredient.count}개"
puts "  - 제품: #{Product.count}개"
puts "  - 사용자: #{User.count}명"
puts "  - 추천: #{Recommendation.count}개"
puts "  - 제품-성분 연결: #{ProductIngredient.count}개"
