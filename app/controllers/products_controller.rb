class ProductsController < ActionController::API

  def index
    @products = Product.all #인스턴스 변수
  end

  def show
    @product = Product.find(params[:id])
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)

    if @product.save
      render json: @product, status: :created
    else 
      render json: { errors: @product.errors.full_messages}, status: :unprocessable_entity
    end
  end

  private 

  def product_params
    # JSON 요청 바디에서 name만 허용
    params.require(:product).permit!
  end
end
