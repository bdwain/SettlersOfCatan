class CreateResources < ActiveRecord::Migration
  def change
    create_table :resources do |t|
      t.references :player, :null => false
      t.integer :type, :null => false
      t.integer :count, :null => false, :default => 0
    end
    add_index :resources, :player_id
    add_index :resources, [:player_id, :type], :unique => true
  end
end
