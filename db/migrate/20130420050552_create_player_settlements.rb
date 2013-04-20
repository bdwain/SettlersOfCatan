class CreatePlayerSettlements < ActiveRecord::Migration
  def change
    create_table :player_settlements do |t|
      t.references :game_player, :null => false
      t.integer :vertex_x, :null => false
      t.integer :vertex_y, :null => false
      t.boolean :is_city, :null => false, :default => false

      t.timestamps
    end
    add_index :player_settlements, :game_player_id
  end
end
