#!/usr/bin/env ruby

# "내 화장품을 찾아줘!" 프로젝트 완전 초기 설정 스크립트
# Ruby on Rails + MCP 서버 기반 AI 화장품 추천 서비스

puts "🎯 '내 화장품을 찾아줘!' 프로젝트 완전 초기 설정 시작..."
puts "=" * 60

# 0. 사용자 확인
puts "⚠️  주의: 이 스크립트는 기존 데이터를 모두 삭제합니다!"
puts "계속하시겠습니까? (y/N): "
response = gets.chomp.downcase

unless response == 'y' || response == 'yes'
  puts "❌ 스크립트 실행이 취소되었습니다."
  exit
end

# 1. 완전한 프로젝트 클린
puts "🧹 프로젝트 완전 클린 중..."

# 데이터베이스 완전 삭제
puts "🗄️ 데이터베이스 삭제 중..."
system("rails db:drop 2>/dev/null")
system("rm -f storage/development.sqlite3") if File.exist?("storage/development.sqlite3")
system("rm -f storage/test.sqlite3") if File.exist?("storage/test.sqlite3")
system("rm -f db/schema.rb") if File.exist?("db/schema.rb")
puts "  ✅ 데이터베이스 삭제 완료"

# 기존 마이그레이션 파일들 모두 삭제
puts "📁 마이그레이션 파일 정리 중..."
Dir.glob("db/migrate/*.rb").each do |file|
  File.delete(file)
  puts "  삭제: #{file}"
end

# 기존 모델 파일들 삭제 (ApplicationRecord 제외)
puts "🏗️ 모델 파일 정리 중..."
Dir.glob("app/models/*.rb").each do |file|
  unless file.include?("application_record.rb") || file.include?("concerns")
    File.delete(file)
    puts "  삭제: #{file}"
  end
end

# 기존 컨트롤러 파일들 삭제 (ApplicationController 제외)
puts "🎮 컨트롤러 파일 정리 중..."
Dir.glob("app/controllers/*.rb").each do |file|
  unless file.include?("application_controller.rb") || file.include?("concerns")
    File.delete(file)
    puts "  삭제: #{file}"
  end
end

# 기존 뷰 디렉토리들 삭제 (layouts 제외)
puts "👁️ 뷰 디렉토리 정리 중..."
Dir.glob("app/views/*").each do |dir|
  if Dir.exist?(dir) && !dir.include?("layouts") && !dir.include?("pwa")
    system("rm -rf #{dir}")
    puts "  삭제: #{dir}"
  end
end

# 기존 테스트 파일들 삭제
puts "🧪 테스트 파일 정리 중..."
Dir.glob("test/**/*.rb").each do |file|
  unless file.include?("test_helper.rb") || file.include?("application_system_test_case.rb")
    File.delete(file)
    puts "  삭제: #{file}"
  end
end

# 기존 테스트 데이터 파일들 삭제
Dir.glob("test/fixtures/*.yml").each do |file|
  File.delete(file)
  puts "  삭제: #{file}"
end

puts "✅ 프로젝트 클린 완료"

# 2. 데이터베이스 재생성
puts "🗄️ 데이터베이스 재생성 중..."
create_result = system("rails db:create")
if create_result
  puts "✅ 데이터베이스 재생성 완료"
else
  puts "❌ 데이터베이스 재생성 실패"
  exit 1
end

# 3. 프로젝트 설정 정의
project_config = {
  models: [
    {
      name: "User",
      attributes: "skin_type:string concerns:string age_group:string",
      validations: {
        skin_type: { presence: true, inclusion: { in: %w[dry oily combination sensitive] } },
        concerns: { presence: true },
        age_group: { presence: true, inclusion: { in: %w[teens twenties thirties forties_plus] } }
      },
      associations: [
        "has_many :recommendations, dependent: :destroy",
        "has_many :recommended_products, through: :recommendations, source: :product"
      ],
      instance_methods: [
        "def skin_concerns",
        "  concerns.split(',').map(&:strip) if concerns.present?",
        "end",
        "",
        "def has_concern?(concern)",
        "  skin_concerns&.include?(concern)",
        "end"
      ],
      class_methods: [
        "def self.find_by_skin_type(skin_type)",
        "  where(skin_type: skin_type)",
        "end",
        "",
        "def self.find_by_age_group(age_group)",
        "  where(age_group: age_group)",
        "end"
      ]
    },
    {
      name: "Product",
      attributes: "name:string brand:string category:string price:integer description:text",
      validations: {
        name: { presence: true },
        brand: { presence: true },
        category: { presence: true, inclusion: { in: %w[moisturizer serum cream toner cleanser gel essence oil sunscreen] } },
        price: { presence: true, numericality: { greater_than: 0 } },
        description: { presence: true }
      },
      associations: [
        "has_many :product_ingredients, dependent: :destroy",
        "has_many :ingredients, through: :product_ingredients",
        "has_many :recommendations, dependent: :destroy",
        "has_many :recommended_users, through: :recommendations, source: :user"
      ],
      instance_methods: [
        "def expensive?",
        "  price > 50000",
        "end",
        "",
        "def affordable?",
        "  price <= 30000",
        "end",
        "",
        "def ingredient_names",
        "  ingredients.pluck(:name)",
        "end",
        "",
        "def has_ingredient?(ingredient_name)",
        "  ingredients.exists?(name: ingredient_name)",
        "end"
      ],
      class_methods: [
        "def self.find_by_category(category)",
        "  where(category: category)",
        "end",
        "",
        "def self.expensive_products",
        "  where(\"price > ?\", 50000)",
        "end",
        "",
        "def self.search_by_name(query)",
        "  where(\"name LIKE ?\", \"%\" + query + \"%\")",
        "end"
      ]
    },
    {
      name: "Ingredient",
      attributes: "name:string description:text effect:string safety_level:string",
      validations: {
        name: { presence: true, uniqueness: true },
        description: { presence: true },
        effect: { presence: true, inclusion: { in: %w[hydration acne aging brightening] } },
        safety_level: { presence: true, inclusion: { in: %w[safe moderate high_risk] } }
      },
      associations: [
        "has_many :product_ingredients, dependent: :destroy",
        "has_many :products, through: :product_ingredients"
      ],
      instance_methods: [
        "def safe?",
        "  safety_level == 'safe'",
        "end",
        "",
        "def high_risk?",
        "  safety_level == 'high_risk'",
        "end"
      ],
      class_methods: [
        "def self.find_by_effect(effect)",
        "  where(effect: effect)",
        "end",
        "",
        "def self.safe_ingredients",
        "  where(safety_level: 'safe')",
        "end"
      ]
    },
    {
      name: "ProductIngredient",
      attributes: "product:references ingredient:references",
      validations: {
        product_id: { uniqueness: { scope: :ingredient_id } }
      },
      associations: [
        "belongs_to :product",
        "belongs_to :ingredient"
      ]
    },
    {
      name: "Recommendation",
      attributes: "user:references product:references score:float reason:text",
      validations: {
        score: { presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 } },
        reason: { presence: true },
        user_id: { uniqueness: { scope: :product_id } }
      },
      associations: [
        "belongs_to :user",
        "belongs_to :product"
      ],
      class_methods: [
        "def self.top_recommendations(user_id, limit = 10)",
        "  where(user_id: user_id).order(score: :desc).limit(limit)",
        "end"
      ]
    }
  ]
}

# 4. 모델 생성 및 설정
puts "🏗️ 모델 생성 및 설정 중..."

project_config[:models].each do |model_config|
  puts "📦 #{model_config[:name]} 모델 생성 중..."
  
  # Rails generator 실행
  generator_result = system("rails generate model #{model_config[:name]} #{model_config[:attributes]} 2>/dev/null")
  unless generator_result
    puts "  ⚠️  #{model_config[:name]} 모델 생성 중 경고 발생 (계속 진행)"
  end
  
  # 모델 파일 내용 생성
  model_content = []
  model_content << "class #{model_config[:name]} < ApplicationRecord"
  
  # 검증 추가
  if model_config[:validations]
    model_content << "  # 검증"
    model_config[:validations].each do |attr, validations|
      validation_str = "validates :#{attr}"
      validations.each do |type, value|
        if value.is_a?(Hash)
          validation_str += ", #{type}: #{value}"
        else
          validation_str += ", #{type}: #{value.inspect}"
        end
      end
      model_content << "  #{validation_str}"
    end
    model_content << ""
  end
  
  # 연관관계 추가
  if model_config[:associations]
    model_content << "  # 연관관계"
    model_config[:associations].each do |association|
      model_content << "  #{association}"
    end
    model_content << ""
  end
  
  # 인스턴스 메서드 추가
  if model_config[:instance_methods]
    model_config[:instance_methods].each do |method|
      model_content << "  #{method}"
    end
    model_content << ""
  end
  
  # 클래스 메서드 추가
  if model_config[:class_methods]
    model_config[:class_methods].each do |method|
      model_content << "  #{method}"
    end
    model_content << ""
  end
  
  model_content << "end"
  
  # 모델 파일 작성
  File.write("app/models/#{model_config[:name].downcase}.rb", model_content.join("\n"))
  puts "  ✅ #{model_config[:name]} 모델 설정 완료"
end

# 5. 디렉토리 생성
puts "📁 프로젝트 디렉토리 생성 중..."
dirs_created = []
dirs_created << "app/mcp/tools" if system("mkdir -p app/mcp/tools")
dirs_created << "app/mcp/schemas" if system("mkdir -p app/mcp/schemas")
dirs_created << "app/services" if system("mkdir -p app/services")
puts "✅ 디렉토리 생성 완료: #{dirs_created.join(', ')}"

# 6. 마이그레이션 실행
puts "🔄 마이그레이션 실행 중..."

migration_result = system("rails db:migrate")
if migration_result
  puts "✅ 마이그레이션 완료"
else
  puts "❌ 마이그레이션 실패"
  puts "🔧 최종 해결 방법:"
  puts "  1. rails db:reset 실행"
  puts "  2. 또는 rails db:drop && rails db:create && rails db:migrate 실행"
  exit 1
end

# 7. 라우트 설정
puts "🛣️ 라우트 설정 중..."
routes_content = <<~RUBY
Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # API Routes
  namespace :api do
    resources :users, only: [:create, :show, :update]
    resources :products, only: [:index, :show]
    resources :ingredients, only: [:index, :show]
    resources :recommendations, only: [:create, :index, :show]
    
    # Custom routes
    post 'recommendations/by_ingredient', to: 'recommendations#by_ingredient'
    get 'products/search', to: 'products#search'
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
RUBY

File.write("config/routes.rb", routes_content)
puts "✅ 라우트 설정 완료"

# 8. 완료 메시지
puts "=" * 60
puts "🎉 프로젝트 완전 초기 설정 완료!"
puts ""
puts "📋 생성된 모델들:"
project_config[:models].each do |model|
  puts "  - #{model[:name]}"
end
puts ""
puts "📁 생성된 디렉토리들:"
puts "  - app/mcp/ (MCP 서버)"
puts "  - app/services/ (비즈니스 로직)"
puts ""
puts "🚀 다음 단계:"
puts "  1. rails server (서버 실행)"
puts "  2. API 컨트롤러 구현"
puts "  3. MCP 서버 구현"
puts "  4. 추천 알고리즘 구현"
puts ""
puts "💡 참고: .cursorrules 파일에 프로젝트 가이드가 포함되어 있습니다."
puts ""
puts "🔧 스크립트 재실행: ruby setup_project_clean.rb" 