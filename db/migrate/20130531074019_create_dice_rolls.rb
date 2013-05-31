class CreateDiceRolls < ActiveRecord::Migration
  def change
    create_table :dice_rolls do |t|
      t.integer :current_player_id, :null => false
      t.integer :turn_num, :null => false
      t.integer :dice_num, :null => false
      t.timestamps
    end
    add_index :dice_rolls, :current_player_id
  end
end
