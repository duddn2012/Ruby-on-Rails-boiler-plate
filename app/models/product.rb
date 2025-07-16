class Product < ApplicationRecord
  # 검증
  validates :name, presence: true
  validates :brand, presence: true
  validates :category, presence: true, inclusion: {in: ["moisturizer", "serum", "cream", "toner", "cleanser", "gel", "essence", "oil", "sunscreen"]}
  validates :price, presence: true, numericality: {greater_than: 0}
  validates :description, presence: true

  # 연관관계
  has_many :product_ingredients, dependent: :destroy
  has_many :ingredients, through: :product_ingredients
  has_many :recommendations, dependent: :destroy
  has_many :recommended_users, through: :recommendations, source: :user

  def expensive?
    price > 50000
  end
  
  def affordable?
    price <= 30000
  end

  def ingredient_names
    ingredients.pluck(:name)
  end
  
  def has_ingredient?(ingredient_name)
    ingredients.exists?(name: ingredient_name)
  end

  def self.find_by_category(category)
    where(category: category)
  end
  
  def self.expensive_products
    where("price > ?", 50000)
  end

  def self.search_by_name(query)
    where("name LIKE ?", "%" + query + "%")
  end

end