class Api::IngredientsController < Api::ApplicationController
  before_action :set_ingredient, only: [:show, :update, :destroy]

  # GET /api/ingredients
  def index
    @ingredients = Ingredient.includes(:products)
    
    # 필터링 옵션
    @ingredients = @ingredients.where(effect: params[:effect]) if params[:effect].present?
    @ingredients = @ingredients.where(safety_level: params[:safety_level]) if params[:safety_level].present?
    
    # 검색
    if params[:q].present?
      @ingredients = @ingredients.where("name ILIKE ? OR description ILIKE ?", 
                                       "%#{params[:q]}%", "%#{params[:q]}%")
    end
    
    # 정렬
    case params[:sort]
    when 'name_asc'
      @ingredients = @ingredients.order(:name)
    when 'name_desc'
      @ingredients = @ingredients.order(name: :desc)
    when 'safety_asc'
      @ingredients = @ingredients.order(:safety_level)
    when 'safety_desc'
      @ingredients = @ingredients.order(safety_level: :desc)
    else
      @ingredients = @ingredients.order(:name)
    end
    
    # 페이지네이션
    @ingredients = @ingredients.page(params[:page]).per(params[:per_page] || 50)
    
    render json: {
      ingredients: @ingredients.as_json(include: :products),
      pagination: {
        current_page: @ingredients.current_page,
        total_pages: @ingredients.total_pages,
        total_count: @ingredients.total_count,
        per_page: @ingredients.limit_value
      }
    }
  end

  # GET /api/ingredients/:id
  def show
    render json: @ingredient.as_json(include: :products)
  end

  # POST /api/ingredients
  def create
    @ingredient = Ingredient.new(ingredient_params)
    
    if @ingredient.save
      render json: @ingredient.as_json(include: :products), status: :created
    else
      render json: { errors: @ingredient.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/ingredients/:id
  def update
    if @ingredient.update(ingredient_params)
      render json: @ingredient.as_json(include: :products)
    else
      render json: { errors: @ingredient.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/ingredients/:id
  def destroy
    @ingredient.destroy
    head :no_content
  end

  # GET /api/ingredients/search
  def search
    query = params[:q]
    
    if query.blank?
      render json: { error: "검색어를 입력해주세요" }, status: :bad_request
      return
    end
    
    @ingredients = Ingredient.includes(:products)
                             .where("name ILIKE ? OR description ILIKE ? OR effect ILIKE ?", 
                                    "%#{query}%", "%#{query}%", "%#{query}%")
                             .order(:name)
                             .page(params[:page])
                             .per(params[:per_page] || 50)
    
    render json: {
      ingredients: @ingredients.as_json(include: :products),
      query: query,
      total_count: @ingredients.total_count
    }
  end

  # GET /api/ingredients/by_effect/:effect
  def by_effect
    effect = params[:effect]
    
    @ingredients = Ingredient.where(effect: effect)
                             .includes(:products)
                             .order(:name)
                             .page(params[:page])
                             .per(params[:per_page] || 50)
    
    render json: {
      ingredients: @ingredients.as_json(include: :products),
      effect: effect,
      total_count: @ingredients.total_count
    }
  end

  # GET /api/ingredients/by_safety/:safety_level
  def by_safety
    safety_level = params[:safety_level]
    
    @ingredients = Ingredient.where(safety_level: safety_level)
                             .includes(:products)
                             .order(:name)
                             .page(params[:page])
                             .per(params[:per_page] || 50)
    
    render json: {
      ingredients: @ingredients.as_json(include: :products),
      safety_level: safety_level,
      total_count: @ingredients.total_count
    }
  end

  # GET /api/ingredients/effects
  def effects
    effects = Ingredient.distinct.pluck(:effect).compact.sort
    
    render json: { effects: effects }
  end

  # GET /api/ingredients/safety_levels
  def safety_levels
    safety_levels = Ingredient.distinct.pluck(:safety_level).compact.sort
    
    render json: { safety_levels: safety_levels }
  end

  # GET /api/ingredients/popular
  def popular
    @ingredients = Ingredient.joins(:product_ingredients)
                             .group('ingredients.id')
                             .order('COUNT(product_ingredients.id) DESC')
                             .limit(params[:limit] || 10)
                             .includes(:products)
    
    render json: {
      ingredients: @ingredients.as_json(include: :products),
      limit: params[:limit] || 10
    }
  end

  private

  def set_ingredient
    @ingredient = Ingredient.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "성분을 찾을 수 없습니다" }, status: :not_found
  end

  def ingredient_params
    params.require(:ingredient).permit(:name, :description, :effect, :safety_level)
  end
end 