class AddDescriptionToIngredients < ActiveRecord::Migration[8.0]
  def change
    add_column :ingredients, :description, :text
  end
end 