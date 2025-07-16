class Api::RecommendationsController < Api::ApplicationController
  before_action :set_recommendation, only: [:show, :update, :destroy]

  # GET /api/recommendations
  def index
    @recommendations = Recommendation.includes(:user, :product)
    
    # 필터링 옵션
    @recommendations = @recommendations.where(user_id: params[:user_id]) if params[:user_id].present?
    @recommendations = @recommendations.where("score >= ?", params[:min_score]) if params[:min_score].present?
    @recommendations = @recommendations.where("score <= ?", params[:max_score]) if params[:max_score].present?
    
    # 정렬
    case params[:sort]
    when 'score_desc'
      @recommendations = @recommendations.order(score: :desc)
    when 'score_asc'
      @recommendations = @recommendations.order(:score)
    when 'created_desc'
      @recommendations = @recommendations.order(created_at: :desc)
    when 'created_asc'
      @recommendations = @recommendations.order(:created_at)
    else
      @recommendations = @recommendations.order(score: :desc)
    end
    
    # 페이지네이션
    @recommendations = @recommendations.page(params[:page]).per(params[:per_page] || 20)
    
    render json: {
      recommendations: @recommendations.as_json(include: [:user, :product]),
      pagination: {
        current_page: @recommendations.current_page,
        total_pages: @recommendations.total_pages,
        total_count: @recommendations.total_count,
        per_page: @recommendations.limit_value
      }
    }
  end

  # GET /api/recommendations/:id
  def show
    render json: @recommendation.as_json(include: [:user, :product])
  end

  # POST /api/recommendations
  def create
    @recommendation = Recommendation.new(recommendation_params)
    
    if @recommendation.save
      render json: @recommendation.as_json(include: [:user, :product]), status: :created
    else
      render json: { errors: @recommendation.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/recommendations/:id
  def update
    if @recommendation.update(recommendation_params)
      render json: @recommendation.as_json(include: [:user, :product])
    else
      render json: { errors: @recommendation.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/recommendations/:id
  def destroy
    @recommendation.destroy
    head :no_content
  end

  # POST /api/recommendations/generate
  def generate
    user_id = params[:user_id]
    
    unless user_id.present?
      render json: { error: "사용자 ID가 필요합니다" }, status: :bad_request
      return
    end
    
    user = User.find(user_id)
    recommendations = generate_recommendations_for_user(user)
    
    render json: {
      user: user.as_json,
      recommendations: recommendations,
      generated_at: Time.current
    }
  rescue ActiveRecord::RecordNotFound
    render json: { error: "사용자를 찾을 수 없습니다" }, status: :not_found
  end

  # POST /api/recommendations/by_ingredient
  def by_ingredient
    ingredient_name = params[:ingredient]
    user_id = params[:user_id]
    
    unless ingredient_name.present?
      render json: { error: "성분명이 필요합니다" }, status: :bad_request
      return
    end
    
    ingredient = Ingredient.find_by(name: ingredient_name)
    
    unless ingredient
      render json: { error: "해당 성분을 찾을 수 없습니다" }, status: :not_found
      return
    end
    
    products = Product.joins(:product_ingredients)
                      .where(product_ingredients: { ingredient_id: ingredient.id })
                      .includes(:ingredients)
    
    if user_id.present?
      user = User.find(user_id)
      recommendations = products.map do |product|
        score = calculate_product_score(user, product)
        {
          product: product.as_json(include: :ingredients),
          score: score,
          reason: "요청하신 성분 '#{ingredient_name}'이 포함된 제품입니다"
        }
      end.sort_by { |rec| -rec[:score] }
    else
      recommendations = products.map do |product|
        {
          product: product.as_json(include: :ingredients),
          score: 50.0, # 기본 점수
          reason: "요청하신 성분 '#{ingredient_name}'이 포함된 제품입니다"
        }
      end
    end
    
    render json: {
      ingredient: ingredient.as_json,
      recommendations: recommendations,
      total_count: recommendations.count
    }
  rescue ActiveRecord::RecordNotFound
    render json: { error: "사용자를 찾을 수 없습니다" }, status: :not_found
  end

  # GET /api/recommendations/user/:user_id
  def user_recommendations
    user_id = params[:user_id]
    
    @recommendations = Recommendation.where(user_id: user_id)
                                    .includes(:product)
                                    .order(score: :desc)
                                    .page(params[:page])
                                    .per(params[:per_page] || 20)
    
    render json: {
      recommendations: @recommendations.as_json(include: :product),
      user_id: user_id,
      total_count: @recommendations.total_count
    }
  rescue ActiveRecord::RecordNotFound
    render json: { error: "사용자를 찾을 수 없습니다" }, status: :not_found
  end

  # GET /api/recommendations/stats
  def stats
    total_recommendations = Recommendation.count
    avg_score = Recommendation.average(:score) || 0
    top_recommendations = Recommendation.includes(:product)
                                       .order(score: :desc)
                                       .limit(10)
    
    render json: {
      total_recommendations: total_recommendations,
      average_score: avg_score.round(2),
      top_recommendations: top_recommendations.as_json(include: [:user, :product])
    }
  end

  private

  def set_recommendation
    @recommendation = Recommendation.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "추천을 찾을 수 없습니다" }, status: :not_found
  end

  def recommendation_params
    params.require(:recommendation).permit(:user_id, :product_id, :score, :reason)
  end

  def generate_recommendations_for_user(user)
    products = Product.includes(:ingredients)
    recommendations = []
    
    products.each do |product|
      score = calculate_product_score(user, product)
      
      if score > 30 # 최소 점수 기준
        recommendation = Recommendation.create!(
          user: user,
          product: product,
          score: score,
          reason: generate_recommendation_reason(user, product, score)
        )
        
        recommendations << {
          product: product.as_json(include: :ingredients),
          score: score,
          reason: recommendation.reason
        }
      end
    end
    
    recommendations.sort_by { |rec| -rec[:score] }.first(20) # 상위 20개만 반환
  end

  def calculate_product_score(user, product)
    score = 0
    
    # 1. 피부타입 매칭 (40점)
    if user.skin_type.present? && product.category.present?
      skin_type_score = calculate_skin_type_match(user.skin_type, product.category)
      score += skin_type_score * 0.4
    end
    
    # 2. 고민사항 매칭 (30점)
    if user.concerns.present?
      concerns_score = calculate_concerns_match(user.concerns, product.ingredients)
      score += concerns_score * 0.3
    end
    
    # 3. 연령대 매칭 (20점)
    if user.age_group.present?
      age_score = calculate_age_group_match(user.age_group, product.category)
      score += age_score * 0.2
    end
    
    # 4. 가격대 매칭 (10점)
    price_score = calculate_price_match(product.price)
    score += price_score * 0.1
    
    score.round(2)
  end

  def calculate_skin_type_match(skin_type, category)
    # 피부타입별 카테고리 매칭 점수
    skin_type_matches = {
      'dry' => ['moisturizer', 'cream', 'oil', 'serum'],
      'oily' => ['cleanser', 'toner', 'gel', 'essence'],
      'combination' => ['moisturizer', 'serum', 'essence'],
      'sensitive' => ['gentle', 'hypoallergenic', 'fragrance_free']
    }
    
    matches = skin_type_matches[skin_type.downcase] || []
    matches.include?(category.downcase) ? 100 : 30
  end

  def calculate_concerns_match(concerns, ingredients)
    # 고민사항별 성분 매칭 점수
    concern_ingredients = {
      'acne' => ['salicylic_acid', 'benzoyl_peroxide', 'niacinamide', 'zinc'],
      'aging' => ['retinol', 'vitamin_c', 'peptide', 'hyaluronic_acid'],
      'brightening' => ['vitamin_c', 'niacinamide', 'alpha_arbutin', 'kojic_acid'],
      'hydration' => ['hyaluronic_acid', 'glycerin', 'ceramide', 'squalane']
    }
    
    total_score = 0
    concern_list = concerns.split(',').map(&:strip)
    
    concern_list.each do |concern|
      target_ingredients = concern_ingredients[concern.downcase] || []
      ingredient_names = ingredients.map(&:name).map(&:downcase)
      
      matches = target_ingredients.count { |target| ingredient_names.include?(target) }
      total_score += (matches.to_f / target_ingredients.length) * 100 if target_ingredients.any?
    end
    
    (total_score / concern_list.length).round(2)
  end

  def calculate_age_group_match(age_group, category)
    # 연령대별 카테고리 매칭 점수
    age_matches = {
      'teens' => ['cleanser', 'moisturizer', 'sunscreen'],
      'twenties' => ['serum', 'essence', 'moisturizer'],
      'thirties' => ['anti_aging', 'serum', 'eye_cream'],
      'forties_plus' => ['anti_aging', 'firming', 'wrinkle_care']
    }
    
    matches = age_matches[age_group.downcase] || []
    matches.include?(category.downcase) ? 100 : 50
  end

  def calculate_price_match(price)
    # 가격대별 점수 (저가일수록 높은 점수)
    case price
    when 0..10000
      100
    when 10001..30000
      80
    when 30001..50000
      60
    when 50001..100000
      40
    else
      20
    end
  end

  def generate_recommendation_reason(user, product, score)
    reasons = []
    
    if user.skin_type.present?
      reasons << "#{user.skin_type} 피부에 적합한 #{product.category} 제품"
    end
    
    if user.concerns.present?
      concerns = user.concerns.split(',').map(&:strip).first(2)
      reasons << "#{concerns.join(', ')} 고민 해결에 도움"
    end
    
    if score > 80
      reasons << "매우 높은 추천 점수"
    elsif score > 60
      reasons << "높은 추천 점수"
    end
    
    reasons.join(", ")
  end
end 