class GamePlayer < ActiveRecord::Base
  belongs_to :game, :inverse_of => :game_players
  belongs_to :user
  has_many :game_player_resources, :inverse_of => :game_player
  has_many :game_development_cards, :inverse_of => :game_player
  has_many :player_settlements, :inverse_of => :game_player

  attr_accessible :color, :turn_num, :turn_status

  validates :color, :presence => true, :numericality => {:only_integer => true}
  
  validates :turn_num, :presence => true, 
            :numericality => {:only_integer => true, :greater_than => 0}

  validates :turn_status, :presence => true, :numericality => {:only_integer => true}

end
