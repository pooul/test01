class CreateGuitars < ActiveRecord::Migration
  def change
    create_table :guitars do |t|
      t.string :name
      t.integer :price

      t.timestamps null: false
    end
  end
end
