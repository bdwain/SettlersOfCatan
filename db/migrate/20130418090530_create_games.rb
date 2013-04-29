class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.integer :num_players, :null => false
      t.integer :status, :null => false, :default => 1
      t.integer :creator_id, :null => false
      t.integer :winner_id, :null => true
      t.integer :robber_x, :null => false, :default => 0
      t.integer :robber_y, :null => false, :default => 0
      t.integer :middle_row_width, :null => false, :default => 5
      t.integer :num_rows, :null => false, :default => 5
      t.integer :num_middle_rows, :null => false, :default => 1

      t.timestamps
    end
    add_index :games, :creator_id
    add_index :games, :winner_id
  end
end
