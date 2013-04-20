class GameDevelopmentCard < ActiveRecord::Base
  belongs_to :game_player, :inverse_of => :game_development_cards
  belongs_to :game, :inverse_of => :game_development_cards
  attr_accessible :card_position, :card_type, :was_used

  validates :card_position, :allow_nil=> true, 
            :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}

  validates :card_type, :presence => true, :numericality => {:only_integer => true}
  
  validates_presence_of :was_used
            
end
