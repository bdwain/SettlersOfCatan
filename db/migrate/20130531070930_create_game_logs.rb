class CreateGameLogs < ActiveRecord::Migration
  def change
    create_table :game_logs do |t|
      t.integer :current_player_id, :null => false
      t.integer :turn_num, :null => false
      t.integer :recipient_id, :null => true
      t.text :msg, :null => false
      t.timestamps
    end
    add_index :game_logs, :current_player_id
  end
end
