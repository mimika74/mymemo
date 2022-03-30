class RemoveMonthFromExpenses < ActiveRecord::Migration[5.2]
  def change
    remove_column :expenses, :month, :date
  end
end
