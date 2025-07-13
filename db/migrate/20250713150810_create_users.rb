class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :skin_type
      t.string :concerns
      t.string :age_group

      t.timestamps
    end
  end
end
