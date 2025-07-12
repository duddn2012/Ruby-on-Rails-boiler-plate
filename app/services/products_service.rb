class ProductsService
    def initialize(product, order_params)
        @user = user
        @order_params = order_params
    end

    def call
        ActiveRecord::Base.transaction do
            order = Order.create!(@order_params)
            # 여러 모델 조작 예시
            inventory = Inventory.find(order.product_id)
            inventory.decrement!(:stock, order.quantity)
            
            ResultDto.new(order, inventory)
        end
    rescue => each
        nil
    end

    
end
