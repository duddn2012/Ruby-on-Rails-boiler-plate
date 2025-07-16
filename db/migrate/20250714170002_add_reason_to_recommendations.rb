class AddReasonToRecommendations < ActiveRecord::Migration[8.0]
  def change
    add_column :recommendations, :reason, :text
  end
end 