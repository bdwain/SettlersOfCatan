class CreateSettlements < ActiveRecord::Migration
  def change
    create_table :settlements do |t|
      t.references :player, :null => false
      t.integer :vertex_x, :null => false
      t.integer :vertex_y, :null => false
      t.boolean :is_city, :null => false, :default => false
    end
    add_index :settlements, :player_id
  end
end
