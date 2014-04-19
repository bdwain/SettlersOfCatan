class Road < ActiveRecord::Base
  belongs_to :player, :inverse_of => :roads
  attr_accessible :edge_x, :edge_y, :side

  validates_presence_of :player

  validates :edge_x, :presence => true, :numericality => {:only_integer => true}

  validates :edge_y, :presence => true, :numericality => {:only_integer => true}

  validates :side, :presence => true, :inclusion => {:in => 0..2 }
end
