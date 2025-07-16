class Api::ProductsController < Api::ApplicationController
  before_action :set_product, only: [:show, :update, :destroy]

  # GET /api/products
  def index
    @products = Product.includes(:ingredients)
    
    # 필터링 옵션
    @products = @products.where(category: params[:category]) if params[:category].present?
    @products = @products.where(brand: params[:brand]) if params[:brand].present?
    @products = @products.where("price <= ?", params[:max_price]) if params[:max_price].present?
    @products = @products.where("price >= ?", params[:min_price]) if params[:min_price].present?
    
    # 정렬
    case params[:sort]
    when 'price_asc'
      @products = @products.order(:price)
    when 'price_desc'
      @products = @products.order(price: :desc)
    when 'name_asc'
      @products = @products.order(:name)
    when 'name_desc'
      @products = @products.order(name: :desc)
    else
      @products = @products.order(created_at: :desc)
    end
    
    # 페이지네이션
    @products = @products.page(params[:page]).per(params[:per_page] || 20)
    
    render json: {
      products: @products.as_json(include: :ingredients),
      pagination: {
        current_page: @products.current_page,
        total_pages: @products.total_pages,
        total_count: @products.total_count,
        per_page: @products.limit_value
      }
    }
  end

  # GET /api/products/:id
  def show
    render json: @product.as_json(include: :ingredients)
  end

  # POST /api/products
  def create
    @product = Product.new(product_params)
    
    if @product.save
      render json: @product.as_json(include: :ingredients), status: :created
    else
      render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/products/:id
  def update
    if @product.update(product_params)
      render json: @product.as_json(include: :ingredients)
    else
      render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/products/:id
  def destroy
    @product.destroy
    head :no_content
  end

  # GET /api/products/search
  def search
    query = params[:q]
    
    if query.blank?
      render json: { error: "검색어를 입력해주세요" }, status: :bad_request
      return
    end
    
    @products = Product.includes(:ingredients)
                       .where("name ILIKE ? OR brand ILIKE ? OR description ILIKE ?", 
                              "%#{query}%", "%#{query}%", "%#{query}%")
                       .order(:name)
                       .page(params[:page])
                       .per(params[:per_page] || 20)
    
    render json: {
      products: @products.as_json(include: :ingredients),
      query: query,
      total_count: @products.total_count
    }
  end

  # GET /api/products/by_ingredient/:ingredient_id
  def by_ingredient
    ingredient_id = params[:ingredient_id]
    
    @products = Product.joins(:product_ingredients)
                       .where(product_ingredients: { ingredient_id: ingredient_id })
                       .includes(:ingredients)
                       .order(:name)
                       .page(params[:page])
                       .per(params[:per_page] || 20)
    
    render json: {
      products: @products.as_json(include: :ingredients),
      ingredient_id: ingredient_id,
      total_count: @products.total_count
    }
  end

  # GET /api/products/categories
  def categories
    categories = Product.distinct.pluck(:category).compact.sort
    
    render json: { categories: categories }
  end

  # GET /api/products/brands
  def brands
    brands = Product.distinct.pluck(:brand).compact.sort
    
    render json: { brands: brands }
  end

  private

  def set_product
    @product = Product.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "제품을 찾을 수 없습니다" }, status: :not_found
  end

  def product_params
    params.require(:product).permit(:name, :brand, :category, :price, :description, 
                                   ingredient_ids: [])
  end
end 