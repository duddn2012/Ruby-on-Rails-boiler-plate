class User < ApplicationRecord
  # 검증
  validates :skin_type, presence: true, inclusion: {in: ["dry", "oily", "combination", "sensitive"]}
  validates :concerns, presence: true
  validates :age_group, presence: true, inclusion: {in: ["teens", "twenties", "thirties", "forties_plus"]}

  # 연관관계
  has_many :recommendations, dependent: :destroy
  has_many :recommended_products, through: :recommendations, source: :product

  def skin_concerns
    concerns.split(',').map(&:strip) if concerns.present?
  end
  
  def has_concern?(concern)
    skin_concerns&.include?(concern)
  end

  def self.find_by_skin_type(skin_type)
    where(skin_type: skin_type)
  end
  
  def self.find_by_age_group(age_group)
    where(age_group: age_group)
  end

end