class ProductsController < ActionController::API
  before_action :set_product, only: %i[show]

  def index
    @products = Product.all #인스턴스 변수
  end

  def show
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
    params.require(:product).permit(:name, :description, :price)
    #params.expect(product: [ :name])
  end

  def show
    product = Product.find(params[:id])
    render json: {
      name: product.name,
      price: product.price,
      created_at: product.created_at
    }
  end

  def set_product
    @product = Product.find(params[:id])
  end
end
