class Api::UsersController < Api::ApplicationController
  before_action :set_user, only: [:show, :update]

  # POST /api/users
  def create
    @user = User.new(user_params)
    
    if @user.save
      render json: {
        user: @user,
        message: "사용자 정보가 성공적으로 등록되었습니다."
      }, status: :created
    else
      render json: {
        errors: @user.errors.full_messages,
        message: "사용자 정보 등록에 실패했습니다."
      }, status: :unprocessable_entity
    end
  end

  # GET /api/users/:id
  def show
    render json: {
      user: @user,
      recommendations: @user.recommendations.count,
      recommended_products: @user.recommended_products.count
    }
  end

  # PATCH/PUT /api/users/:id
  def update
    if @user.update(user_params)
      render json: {
        user: @user,
        message: "사용자 정보가 성공적으로 업데이트되었습니다."
      }
    else
      render json: {
        errors: @user.errors.full_messages,
        message: "사용자 정보 업데이트에 실패했습니다."
      }, status: :unprocessable_entity
    end
  end

  # GET /api/users/:id/recommendations
  def recommendations
    @user = User.find(params[:id])
    @recommendations = @user.recommendations.includes(:product).order(score: :desc)
    
    render json: {
      user: @user,
      recommendations: @recommendations.map do |rec|
        {
          id: rec.id,
          score: rec.score,
          product: {
            id: rec.product.id,
            name: rec.product.name,
            brand: rec.product.brand,
            category: rec.product.category,
            price_range: rec.product.price_range
          }
        }
      end
    }
  end

  # GET /api/users/:id/skin_analysis
  def skin_analysis
    @user = User.find(params[:id])
    
    render json: {
      user: @user,
      skin_concerns: @user.skin_concerns,
      has_concern: {
        acne: @user.has_concern?("여드름"),
        wrinkles: @user.has_concern?("주름"),
        whitening: @user.has_concern?("미백"),
        moisturizing: @user.has_concern?("보습")
      },
      recommendations_count: @user.recommendations.count
    }
  end

  private

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: {
      error: "사용자를 찾을 수 없습니다.",
      message: "존재하지 않는 사용자 ID입니다."
    }, status: :not_found
  end

  def user_params
    # Strong Parameters (Java Spring의 @Valid와 유사)
    params.require(:user).permit(:skin_type, :concerns, :age_group)
  end
end
