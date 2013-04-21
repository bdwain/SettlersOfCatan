class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.references :game, :null => false
      t.references :user, :null => false
      t.integer :turn_num, :null => false
      t.integer :turn_status, :null => true
      t.integer :color, :null => false
      t.datetime :turn_deadline, :null => true

      t.timestamps
    end
    add_index :players, :game_id
    add_index :players, :user_id
  end
end
