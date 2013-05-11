class CreateHexes < ActiveRecord::Migration
  def change
    create_table :hexes do |t|
      t.references :map, :null => false
      t.integer :pos_x, :null => false
      t.integer :pos_y, :null => false
      t.integer :resource_type, :null => false
      t.integer :dice_num, :null => true
    end
    add_index :hexes, :map_id
  end
end
