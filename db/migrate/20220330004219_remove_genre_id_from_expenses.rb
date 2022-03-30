class RemoveGenreIdFromExpenses < ActiveRecord::Migration[5.2]
  def change
    remove_column :expenses, :genre_id, :integer
  end
end
