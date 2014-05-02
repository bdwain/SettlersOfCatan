class Settlement < ActiveRecord::Base
  belongs_to :player, :inverse_of => :settlements

  validates_presence_of :player

  validates :vertex_x, :presence => true, :numericality => {:only_integer => true}

  validates :vertex_y, :presence => true, :numericality => {:only_integer => true}

  validates :side, :presence => true, :inclusion => {:in => 0..1 }
end
