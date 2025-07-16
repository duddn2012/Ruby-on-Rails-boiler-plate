class CreateIngredients < ActiveRecord::Migration[8.0]
  def change
    create_table :ingredients do |t|
      t.string :name
      t.string :effect
      t.string :safety_level

      t.timestamps
    end
  end
end
