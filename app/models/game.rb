class Game < ActiveRecord::Base
  belongs_to :winner, :class_name => 'User', :foreign_key => 'winner_id'
  has_many :game_hexes, :inverse_of => :game
  has_many :game_harbors, :inverse_of => :game
  has_many :game_players, :inverse_of => :game
  has_many :game_development_cards, :inverse_of => :game

  attr_accessible :game_status, :middle_row_width, :num_middle_rows, :num_players, :num_rows, :robber_x, :robber_y

  private
  STATUS_WAITING_FOR_PLAYERS = 1
  STATUS_ROLLING_FOR_TURN_ORDER = 2
  STATUS_PLACING_INITIAL_PIECES = 3
  STATUS_PLAYING = 4
  STATUS_COMPLETED = 5

  public
  validates :game_status, :presence => true, 
            :inclusion => { :in => [ STATUS_WAITING_FOR_PLAYERS,
             STATUS_ROLLING_FOR_TURN_ORDER, STATUS_PLACING_INITIAL_PIECES,
             STATUS_PLAYING, STATUS_COMPLETED ] }

  validates :middle_row_width, :presence => true, 
            :numericality => {:only_integer => true, :greater_than_or_equal_to => 5}

  validates :num_middle_rows, :presence => true, 
            :numericality => {:only_integer => true, :greater_than => 0}

  validates :num_rows, :presence => true, 
            :numericality => {:only_integer => true, :greater_than_or_equal_to => 5}

  validates :num_players, :presence => true, :inclusion => { :in => 3.upto(4) }, 
            :numericality => {:only_integer => true}

  #position of the robber
  validates :robber_x, :presence => true, :numericality => {:only_integer => true}
  validates :robber_y, :presence => true, :numericality => {:only_integer => true}
  
  def is_waiting_for_players?
    self.game_status == STATUS_WAITING_FOR_PLAYERS
  end

  def is_rolling_for_turn_order?
    self.game_status == STATUS_ROLLING_FOR_TURN_ORDER
  end

  def is_placing_initial_pieces?
    self.game_status == STATUS_PLACING_INITIAL_PIECES
  end

  def is_playing?
    self.game_status == STATUS_PLAYING
  end

  def is_completed?
    self.game_status == STATUS_COMPLETED
  end

  #def contains_user?(user)
    #game_players.contains()
  #end
end
