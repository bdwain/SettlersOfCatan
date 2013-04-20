class CreatePlayerRoads < ActiveRecord::Migration
  def change
    create_table :player_roads do |t|
      t.references :game_player, :null => false
      t.integer :edge_x, :null => false
      t.integer :edge_y, :null => false

      t.timestamps
    end
    add_index :player_roads, :game_player_id
  end
end
