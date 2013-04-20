class CreateGamePlayers < ActiveRecord::Migration
  def change
    create_table :game_players do |t|
      t.references :game, :null => false
      t.references :user, :null => false
      t.integer :turn_num, :null => false
      t.integer :turn_status, :null => false
      t.integer :color, :null => false
      t.datetime :turn_deadline, :null => true

      t.timestamps
    end
    add_index :game_players, :game_id
    add_index :game_players, :user_id
  end
end
