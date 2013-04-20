class GameHarbor < ActiveRecord::Base
  belongs_to :game, :inverse_of => :game_harbors
  attr_accessible :edge_x, :edge_y, :resource_type

  validates :resource_type, :allow_nil => true, :numericality => {:only_integer => true}
  
  validates :edge_x, :presence => true, 
            :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}

  validates :edge_y, :presence => true, 
            :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
end
