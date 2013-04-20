class CreateGameHexes < ActiveRecord::Migration
  def change
    create_table :game_hexes do |t|
      t.references :game, :null => false
      t.integer :pos_x, :null => false
      t.integer :pos_y, :null => false
      t.integer :hex_type, :null => false
      t.integer :dice_num, :null => false

      t.timestamps
    end
    add_index :game_hexes, :game_id
  end
end
