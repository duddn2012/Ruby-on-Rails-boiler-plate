class Recommendation < ApplicationRecord
  # 검증
  validates :score, presence: true, numericality: {greater_than_or_equal_to: 0, less_than_or_equal_to: 100}
  validates :reason, presence: true
  validates :user_id, uniqueness: {scope: :product_id}

  # 연관관계
  belongs_to :user
  belongs_to :product

  def self.top_recommendations(user_id, limit = 10)
    where(user_id: user_id).order(score: :desc).limit(limit)
  end

end