class Game < ActiveRecord::Base
  belongs_to :creator, :class_name => 'User', :foreign_key => 'creator_id'
  belongs_to :winner, :class_name => 'User', :foreign_key => 'winner_id'
  belongs_to :map
  has_many :players, :inverse_of => :game, :autosave => true, :dependent => :destroy
  has_many :development_cards, :inverse_of => :game, :autosave => true, :dependent => :destroy

  attr_accessible :num_players

  private
  STATUS_WAITING_FOR_PLAYERS = 1
  STATUS_PLACING_INITIAL_PIECES = 2
  STATUS_PLAYING = 3
  STATUS_COMPLETED = 4

  public
  validates_presence_of :creator, :map

  validates :status, :presence => true, 
            :inclusion => { :in => [STATUS_WAITING_FOR_PLAYERS, STATUS_PLACING_INITIAL_PIECES, 
             STATUS_PLAYING, STATUS_COMPLETED] }

  validates :num_players, :presence => true, :inclusion => { :in => 3.upto(4) }, 
            :numericality => {:only_integer => true}

  validates :turn_num, :presence => true, 
            :numericality => {:only_integer => true, :greater_than => 0}

  #position of the robber
  validates :robber_x, :presence => true, :numericality => {:only_integer => true}
  validates :robber_y, :presence => true, :numericality => {:only_integer => true}

  def waiting_for_players?
    status == STATUS_WAITING_FOR_PLAYERS
  end

  def placing_initial_pieces?
    status == STATUS_PLACING_INITIAL_PIECES
  end

  def playing?
    status == STATUS_PLAYING
  end

  def completed?
    status == STATUS_COMPLETED
  end

  #returns the player for a corresponding user, or nil if they aren't playing
  #Since this works for anything with an id, and id's are not guaranteed to be unique 
  #across different types of items, would it make sense to use email address?
  def player(user)
    players.detect { |p| p.user_id == user.id } if user != nil
  end

  def player?(user)
    player(user) != nil
  end  

  #this allows us to roll back game creation if the player fails to be added for the
  #creator. this would be an unexpected error, but at least no one will ever be left
  #wondering why they're not in the game they just created when they normally are
  after_create :after_create_add_creators_player
  def after_create_add_creators_player
    raise ActiveRecord::Rollback unless add_user?(creator)
  end

  def add_user?(user)
    if user != nil && user.confirmed? && waiting_for_players? && !player?(user) 
      player = players.build
      player.user = user
      save
    end
  end

  def remove_player?(player)
    if waiting_for_players? && player != nil && players.find_by_id(player.id) != nil
      #the size check is a fallback if the creator somehow leaves 
      #without deleting the game. It's just to avoid old empty games
      if player.user == creator || players.size == 1
        destroy
      else
        player.destroy
      end
    end
  end
  
  #when saving a game, initialize it for play if it's full but status is still waiting
  before_save do
    return true if num_players != players.length || !waiting_for_players?

    #give each player their own turn
    players.shuffle!.each_with_index do |player, index|
      player.turn_num = index + 1
      player.turn_status = (index == 0 ? PLACING_INITIAL_PIECE : WAITING_FOR_TURN)
    end

    14.times { development_cards.build(type: KNIGHT) }
    5.times { development_cards.build(type: VICTORY_POINT) }
    2.times do
      development_cards.build(type: ROAD_BUILDING)
      development_cards.build(type: YEAR_OF_PLENTY)
      development_cards.build(type: MONOPOLY)
    end

    development_cards.shuffle!.each_with_index { |card, index| card.position = index }

    self.status = STATUS_PLACING_INITIAL_PIECES
  end
end
