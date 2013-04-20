class GamePlayerResource < ActiveRecord::Base
  belongs_to :game_player, :inverse_of => :game_player_resources
  attr_accessible :resource_type

  validates :resource_type, :presence => true, :numericality => {:only_integer => true}
  
end
