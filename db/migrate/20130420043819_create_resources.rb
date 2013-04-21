class CreateResources < ActiveRecord::Migration
  def change
    create_table :resources do |t|
      t.references :player, :null => false
      t.integer :type, :null => false

      t.timestamps
    end
    add_index :resources, :player_id
  end
end
