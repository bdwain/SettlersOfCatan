class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.integer :num_players, :null => false
      t.integer :game_status, :null => false
      t.integer :winner_id, :null => true
      t.references :map, :null => false
      t.integer :robber_x, :null => false
      t.integer :robber_y, :null => false
      t.integer :middle_row_width, :null => false
      t.integer :num_rows, :null => false
      t.integer :num_middle_rows, :null => false

      t.timestamps
    end
    add_index :games, :winner_id
    add_index :games, :map_id
  end
end
