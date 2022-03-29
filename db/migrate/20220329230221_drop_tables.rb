class DropTables < ActiveRecord::Migration[5.2]
  def change
    drop_table :notifications
    drop_table :aggregates
    drop_table :genres
    
  end
end
