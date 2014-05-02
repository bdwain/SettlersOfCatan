class GameLog < ActiveRecord::Base
  belongs_to :current_player, :class_name => 'Player', :foreign_key => 'current_player_id'
  belongs_to :target, :class_name => 'Player', :foreign_key => 'target_id'

  validates_presence_of :current_player, :target, :turn_num, :msg
  validates_numericality_of :turn_num, :only_integer => true, :greater_than => 0
end
