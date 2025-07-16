class ProductIngredient < ApplicationRecord
  # 검증
  validates :product_id, uniqueness: {scope: :ingredient_id}

  # 연관관계
  belongs_to :product
  belongs_to :ingredient

end