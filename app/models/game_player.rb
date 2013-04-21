class GamePlayer < ActiveRecord::Base
  belongs_to :game, :inverse_of => :game_players
  belongs_to :user
  has_many :game_player_resources, :inverse_of => :game_player
  has_many :game_development_cards, :inverse_of => :game_player
  has_many :player_settlements, :inverse_of => :game_player
  has_many :player_roads, :inverse_of => :game_player

  attr_accessible :color, :turn_num, :turn_status, :turn_deadline

  validates_presence_of :game_id, :user_id

  validates :color, :presence => true, :numericality => {:only_integer => true}
  
  validates :turn_num, :presence => true, :inclusion => { :in => 3.upto(4) },
            :numericality => {:only_integer => true }

  validates :turn_status, :allow_nil => true, :numericality => {:only_integer => true}
end
