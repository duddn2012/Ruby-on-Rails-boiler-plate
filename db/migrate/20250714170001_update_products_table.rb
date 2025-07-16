class UpdateProductsTable < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :price, :integer
    add_column :products, :description, :text
    remove_column :products, :price_range, :string
  end
end 