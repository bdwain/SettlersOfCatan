class SplitDiceRollsIntoTwoNumbers < ActiveRecord::Migration
  def change
    rename_column :dice_rolls, :dice_num, :die_1
    add_column :dice_rolls, :die_2, :integer, :null => false
  end
end
