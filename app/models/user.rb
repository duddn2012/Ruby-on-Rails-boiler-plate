class User < ApplicationRecord
  # 검증 (Java Spring의 @Valid와 유사)
  validates :skin_type, presence: true, inclusion: { in: %w[건성 지성 복합성 민감성] }
  validates :concerns, presence: true
  validates :age_group, presence: true, inclusion: { in: %w[10대 20대 30대 40대 50대 60대+] }
  
  # 연관관계 (Java Spring의 @OneToMany와 유사)
  has_many :recommendations, dependent: :destroy # CascadeType.REMOVE
  has_many :recommended_products, through: :recommendations, source: :product 
  # @ManyToMany 관계
  # through: :recommendations 는 중간 테이블
  # source: :product 는 실제로 가져올 모델명

  
  # 인스턴스 메서드
  def skin_concerns
    concerns.split(',').map(&:strip) if concerns.present? # strip은 공백 제거
  end
  
  def has_concern?(concern)
    skin_concerns&.include?(concern)
  end
  
  # 클래스 메서드 (Java의 static 메서드와 유사)
  def self.find_by_skin_type(skin_type)
    where(skin_type: skin_type)
  end
  
  def self.find_by_age_group(age_group)
    where(age_group: age_group)
  end
end
