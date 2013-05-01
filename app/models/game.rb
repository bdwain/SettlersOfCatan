class Game < ActiveRecord::Base
  belongs_to :creator, :class_name => 'User', :foreign_key => 'creator_id'
  belongs_to :winner, :class_name => 'User', :foreign_key => 'winner_id'
  has_many :hexes, :inverse_of => :game, :autosave => true, :dependent => :destroy
  has_many :harbors, :inverse_of => :game, :autosave => true, :dependent => :destroy
  has_many :players, :inverse_of => :game, :autosave => true, :dependent => :destroy
  has_many :development_cards, :inverse_of => :game, :autosave => true, :dependent => :destroy

  attr_accessible :status, :middle_row_width, :num_middle_rows, :num_players, :num_rows, :robber_x, :robber_y

  private
  STATUS_WAITING_FOR_PLAYERS = 1
  STATUS_PLAYING = 2
  STATUS_COMPLETED = 3

  public
  validates_presence_of :creator

  validates :status, :presence => true, 
            :inclusion => { :in => [STATUS_WAITING_FOR_PLAYERS, STATUS_PLAYING, STATUS_COMPLETED] }

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
    status == STATUS_WAITING_FOR_PLAYERS
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
  #wondering why they're not in the game they just made when they normally are
  after_create :after_create_add_creators_player
  def after_create_add_creators_player
     raise ActiveRecord::Rollback unless add_user?(creator)
  end

  def add_user?(user)
    if user != nil && user.confirmed? && waiting_for_players? && !player?(user) 
      player = Player.new
      player.user = user
      player.game = self
      players << player
      save
    end
  end

  def remove_player?(player)
    if waiting_for_players? && player != nil && players.find_by_id(player.id) != nil
      #the size check is a fallback if the creator somehow leaves 
      #without deleting the game. It's just to avoid an orphaned game
      if player.user == creator || players.size == 1
        destroy
      else
        player.destroy
      end
    end
  end

  #used when a player's account is deleted. Deletes the game if the player
  #can't safely be removed (via remove_player?, which may also delete the game)
  def player_account_deleted(player)
    if player != nil && players.find_by_id(player.id) != nil
      destroy unless remove_player?(player)
      #maybe throw in an email to the rest of the players letting them know
    end
  end  
end
