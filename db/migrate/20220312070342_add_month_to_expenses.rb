class AddMonthToExpenses < ActiveRecord::Migration[5.2]
  def change
    add_column :expenses, :month, :date
  end
end
