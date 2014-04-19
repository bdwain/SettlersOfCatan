class Harbor < ActiveRecord::Base
  belongs_to :map, :inverse_of => :harbors
  attr_accessible :edge_x, :edge_y, :resource_type, :side

  validates_presence_of :map

  validates :resource_type, :allow_nil => true, :numericality => {:only_integer => true}
  
  validates :edge_x, :presence => true, :numericality => :only_integer

  validates :edge_y, :presence => true, :numericality => :only_integer

  validates :side, :presence => true,
            :numericality => {:only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 2}
end
