class GameLog < ActiveRecord::Base
  belongs_to :current_player, :class_name => 'Player', :foreign_key => 'current_player_id'
  belongs_to :recipient, :class_name => 'Player', :foreign_key => 'recipient_id'
  
  attr_accessible :turn_num, :msg

  validates_presence_of :current_player, :turn_num, :msg
  validates_numericality_of :turn_num, :only_integer => true, :greater_than => 0
end
