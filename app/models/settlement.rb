class Settlement < ActiveRecord::Base
  belongs_to :player, :inverse_of => :settlements
  attr_accessible :vertex_x, :vertex_y

  validates_presence_of :player

  validates :vertex_x, :presence => true, 
            :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}

  validates :vertex_y, :presence => true, 
            :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
end
