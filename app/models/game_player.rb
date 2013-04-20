class GamePlayer < ActiveRecord::Base
  belongs_to :game, :inverse_of => :game_players
  belongs_to :user

  attr_accessible :color, :turn_num, :turn_status

  validates :color, :presence => true, :numericality => {:only_integer => true}
  
  validates :turn_num, :presence => true, 
            :numericality => {:only_integer => true, :greater_than => 0}

  validates :turn_status, :presence => true, :numericality => {:only_integer => true}

end
