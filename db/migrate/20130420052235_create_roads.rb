class CreateRoads < ActiveRecord::Migration
  def change
    create_table :roads do |t|
      t.references :player, :null => false
      t.integer :edge_x, :null => false
      t.integer :edge_y, :null => false
    end
    add_index :roads, :player_id
  end
end
