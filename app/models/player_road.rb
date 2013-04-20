class PlayerRoad < ActiveRecord::Base
  belongs_to :game_player, :inverse_of => :player_roads
  attr_accessible :edge_x, :edge_y

  validates :edge_x, :presence => true, 
            :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}

  validates :edge_y, :presence => true, 
            :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
end
