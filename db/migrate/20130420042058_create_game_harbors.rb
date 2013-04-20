class CreateGameHarbors < ActiveRecord::Migration
  def change
    create_table :game_harbors do |t|
      t.references :game, :null => false
      t.integer :edge_x, :null => false
      t.integer :edge_y, :null => false
      t.integer :resource_type, :null => true

      t.timestamps
    end
    add_index :game_harbors, :game_id
  end
end
