class DiceRoll < ActiveRecord::Base
  belongs_to :current_player, :class_name => 'Player', :foreign_key => 'current_player_id'
  attr_accessible :turn_num, :dice_num

  validates_presence_of :current_player, :turn_num, :dice_num
  validates_numericality_of :turn_num, :only_integer => true, :greater_than => 0
  validates_inclusion_of :dice_num, :in =>  2..12
end
