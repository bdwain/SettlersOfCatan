class DiceRoll < ActiveRecord::Base
  belongs_to :current_player, :class_name => 'Player', :foreign_key => 'current_player_id'

  validates_presence_of :current_player, :turn_num, :die_1, :die_2
  validates_numericality_of :turn_num, :only_integer => true, :greater_than => 0
  validates_inclusion_of :die_1, :in =>  1..6
  validates_inclusion_of :die_2, :in =>  1..6
end
