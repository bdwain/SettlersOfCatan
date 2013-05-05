class Hex < ActiveRecord::Base
  belongs_to :game, :inverse_of => :hexes
  attr_accessible :dice_num, :resource_type, :pos_x, :pos_y

  validates_presence_of :game_id

  validates :dice_num, :inclusion => { :in => 2.upto(12) }, :allow_nil => true

  validates :resource_type, :presence => true, :numericality => {:only_integer => true}
  
  validates :pos_x, :presence => true, 
            :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}

  validates :pos_y, :presence => true, 
            :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}

end
