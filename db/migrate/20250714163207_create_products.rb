class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name
      t.string :brand
      t.string :category
      t.string :price_range

      t.timestamps
    end
  end
end
