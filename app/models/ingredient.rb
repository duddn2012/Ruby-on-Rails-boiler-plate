class Ingredient < ApplicationRecord
  # 검증
  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
  validates :effect, presence: true, inclusion: {in: ["hydration", "acne", "aging", "brightening"]}
  validates :safety_level, presence: true, inclusion: {in: ["safe", "moderate", "high_risk"]}

  # 연관관계
  has_many :product_ingredients, dependent: :destroy
  has_many :products, through: :product_ingredients

  def safe?
    safety_level == 'safe'
  end
  
  def high_risk?
    safety_level == 'high_risk'
  end

  def self.find_by_effect(effect)
    where(effect: effect)
  end
  
  def self.safe_ingredients
    where(safety_level: 'safe')
  end

end