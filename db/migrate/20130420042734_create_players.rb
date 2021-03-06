class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.references :game, :null => false
      t.references :user, :null => false
      t.integer :turn_num, :null => false, :default => 1
      t.integer :turn_status, :null => false, :default => 0
      t.datetime :turn_deadline, :null => true
    end
    add_index :players, :game_id
    add_index :players, :user_id
    add_index :players, [:user_id, :game_id], :unique => true
  end
end
