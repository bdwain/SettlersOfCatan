class Game < ActiveRecord::Base
  belongs_to :winner, :class_name => 'User', :foreign_key => 'winner_id'
  has_many :hexes, :inverse_of => :game
  has_many :harbors, :inverse_of => :game
  has_many :players, :inverse_of => :game
  has_many :development_cards, :inverse_of => :game

  attr_accessible :status, :middle_row_width, :num_middle_rows, :num_players, :num_rows, :robber_x, :robber_y

  private
  STATUS_WAITING_FOR_PLAYERS = 1
  STATUS_ROLLING_FOR_TURN_ORDER = 2
  STATUS_PLACING_INITIAL_PIECES = 3
  STATUS_PLAYING = 4
  STATUS_COMPLETED = 5

  public
  validates :status, :presence => true, 
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
  
  def waiting_for_players?
    self.status == STATUS_WAITING_FOR_PLAYERS
  end

  def rolling_for_turn_order?
    self.status == STATUS_ROLLING_FOR_TURN_ORDER
  end

  def placing_initial_pieces?
    self.status == STATUS_PLACING_INITIAL_PIECES
  end

  def playing?
    self.status == STATUS_PLAYING
  end

  def completed?
    self.status == STATUS_COMPLETED
  end

  #Since this works for anything with an id, and id's are not guaranteed to be unique 
  #across different types of items, would it make sense to use email address?
  def player?(user)
    players.any? { |p| p.user_id == user.id } if user != nil
  end

  def player(user)
    players.detect { |p| p.user_id == user.id } if user != nil
  end

  def add_user?(user)
    if waiting_for_players? && user != nil && user.confirmed? && !player?(user) && players.count < num_players
      player = Player.new()
      player.user = user
      player.game = self
      players.push(player) 
    end
  end

  def remove_player?(player)
    player.destroy if waiting_for_players? && player != nil && players.find_by_id(player.id) != nil
  end
end
