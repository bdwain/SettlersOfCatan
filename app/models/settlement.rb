class Settlement < ActiveRecord::Base
  belongs_to :player, :inverse_of => :settlements
  attr_accessible :vertex_x, :vertex_y, :side

  validates_presence_of :player

  validates :vertex_x, :presence => true, :numericality => :only_integer

  validates :vertex_y, :presence => true, :numericality => :only_integer

  validates :side, :presence => true,
            :numericality => {:only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 1}
end
