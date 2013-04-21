class PlayerSettlement < ActiveRecord::Base
  belongs_to :game_player, :inverse_of => :player_settlements
  attr_accessible :is_city, :vertex_x, :vertex_y

  validates_presence_of :game_player_id

  validates :vertex_x, :presence => true, 
            :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}

  validates :vertex_y, :presence => true, 
            :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
end
