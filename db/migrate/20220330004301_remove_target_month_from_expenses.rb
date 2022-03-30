class RemoveTargetMonthFromExpenses < ActiveRecord::Migration[5.2]
  def change
    remove_column :expenses, :target_month, :date
  end
end
