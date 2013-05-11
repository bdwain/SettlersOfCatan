class CreateHarbors < ActiveRecord::Migration
  def change
    create_table :harbors do |t|
      t.references :map, :null => false
      t.integer :edge_x, :null => false
      t.integer :edge_y, :null => false
      t.integer :resource_type, :null => true
    end
    add_index :harbors, :map_id
  end
end
