class Harbor < ActiveRecord::Base
  belongs_to :game, :inverse_of => :harbors
  attr_accessible :edge_x, :edge_y, :resource_type

  validates_presence_of :game_id

  validates :resource_type, :allow_nil => true, :numericality => {:only_integer => true}
  
  validates :edge_x, :presence => true, 
            :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}

  validates :edge_y, :presence => true, 
            :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
end