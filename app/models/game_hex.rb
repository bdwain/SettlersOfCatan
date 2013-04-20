class GameHex < ActiveRecord::Base
  belongs_to :game, :inverse_of => :game_hexes
  attr_accessible :dice_num, :hex_type, :pos_x, :pos_y

  validates :dice_num, :presence => true, 
            :numericality => {:only_integer => true, :greater_than => 0, :less_than => 7}

  validates :hex_type, :presence => true, :numericality => {:only_integer => true}
  
  validates :pos_x, :presence => true, 
            :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}

  validates :pos_y, :presence => true, 
            :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}

end
