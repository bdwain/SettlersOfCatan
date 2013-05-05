class CreateHexes < ActiveRecord::Migration
  def change
    create_table :hexes do |t|
      t.references :game, :null => false
      t.integer :pos_x, :null => false
      t.integer :pos_y, :null => false
      t.integer :resource_type, :null => false
      t.integer :dice_num, :null => true

      t.timestamps
    end
    add_index :hexes, :game_id
  end
end
