class CreateExpenses < ActiveRecord::Migration[5.2]
  def change
    create_table :expenses do |t|
      t.integer :user_id
      t.integer :genre_id
      t.integer :expense
      t.string :image_id
      t.text :memo
      t.date :target_month
      t.datetime :created_at
      t.datetime :updated_at

      t.timestamps
    end
  end
end
