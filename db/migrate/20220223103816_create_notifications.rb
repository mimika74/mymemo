class CreateNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :notifications do |t|
      t.integer :aggregate_id
      t.integer :total_monthly_expense
      t.date :target_month

      t.timestamps
    end
  end
end
