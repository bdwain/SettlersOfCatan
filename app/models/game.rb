class Game < ActiveRecord::Base
  belongs_to :creator, :class_name => 'User', :foreign_key => 'creator_id'
  belongs_to :winner, :class_name => 'User', :foreign_key => 'winner_id'
  has_many :hexes, :inverse_of => :game, :autosave => true, :dependent => :destroy
  has_many :harbors, :inverse_of => :game, :autosave => true, :dependent => :destroy
  has_many :players, :inverse_of => :game, :autosave => true, :dependent => :destroy
  has_many :development_cards, :inverse_of => :game, :autosave => true, :dependent => :destroy

  attr_accessible :num_players

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
    players.shuffle!.each_with_index { |player, index| player.turn_num = index}

    hexes.build(:resource_type => DESERT)
    4.times do
      hexes.build(:resource_type => WHEAT)
      hexes.build(:resource_type => WOOL)
      hexes.build(:resource_type => WOOD)
    end
    3.times do
      hexes.build(:resource_type => BRICK)
      hexes.build(:resource_type => ORE)
    end
    hexes.shuffle!
    
    #figure out the math later. for now, assume these are all true
    #and it's a normal map
    self.middle_row_width = 5
    self.num_middle_rows = 1
    self.num_rows = 5

    dice_nums = [5,2,6,3,8,10,9,12,11,4,8,10,9,4,5,6,3,11]
    num_rows.times do |x|
      init_y = (x == 0 || x == 4 ? 1 : 0)
      final_y = (x == 2 ? 4 : 3)
      (init_y..final_y).each do |y|
        hexes.first.dice_num = dice_nums.shift unless hexes.first.resource_type == DESERT
        hexes.first.pos_x = x
        hexes.first.pos_y = y
        hexes.push(hexes.shift)
      end
    end

    #do harbors later
    #harbors.push(Harbor.new(:game => self, :resource_type => WHEAT))
    #harbors.push(Harbor.new(:game => self, :resource_type => WOOD))
    #harbors.push(Harbor.new(:game => self, :resource_type => WOOL))
    #harbors.push(Harbor.new(:game => self, :resource_type => BRICK))
    #harbors.push(Harbor.new(:game => self, :resource_type => ORE))
    #3.times do
    #  harbors.push(Harbor.new(:game => self))
    #end
    #harbors.shuffle!

    #do development cards later

    self.status = STATUS_PLAYING
  end
end
