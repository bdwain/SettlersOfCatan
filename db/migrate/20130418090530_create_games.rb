class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.integer :num_players, :null => false, :default => 3
      t.integer :game_status, :null => false, :default => 1
      t.integer :winner_id, :null => true
      t.integer :robber_x, :null => false
      t.integer :robber_y, :null => false
      t.integer :middle_row_width, :null => false
      t.integer :num_rows, :null => false
      t.integer :num_middle_rows, :null => false

      t.timestamps
    end
    add_index :games, :winner_id
  end
end
