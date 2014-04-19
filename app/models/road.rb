class Road < ActiveRecord::Base
  belongs_to :player, :inverse_of => :roads
  attr_accessible :edge_x, :edge_y, :side

  validates_presence_of :player

  validates :edge_x, :presence => true, :numericality => :only_integer

  validates :edge_y, :presence => true, :numericality => :only_integer

  validates :side, :presence => true,
            :numericality => {:only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 2}            
end
