class Harbor < ActiveRecord::Base
  belongs_to :map, :inverse_of => :harbors
  attr_accessible :edge_x, :edge_y, :resource_type, :side

  validates_presence_of :map

  validates :resource_type, :allow_nil => true, :numericality => {:only_integer => true}
  
  validates :edge_x, :presence => true, :numericality => {:only_integer => true}

  validates :edge_y, :presence => true, :numericality => {:only_integer => true}

  validates :side, :presence => true, :inclusion => {:in => 0..2 }
end
