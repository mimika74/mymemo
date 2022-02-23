class CreateAggregates < ActiveRecord::Migration[5.2]
  def change
    create_table :aggregates do |t|
      t.integer :user_id
      t.integer :total_daily_expense
      t.integer :total_expense_by_genres
      t.date :target_month
      t.datetime :created_at
      t.datetime :updated_at

      t.timestamps
    end
  end
end
