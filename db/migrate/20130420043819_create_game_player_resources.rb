class CreateGamePlayerResources < ActiveRecord::Migration
  def change
    create_table :game_player_resources do |t|
      t.references :game_player, :null => false
      t.integer :resource_type, :null => false

      t.timestamps
    end
    add_index :game_player_resources, :game_player_id
  end
end
