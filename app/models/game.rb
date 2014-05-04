class Game < ActiveRecord::Base
  belongs_to :creator, :class_name => 'User', :foreign_key => 'creator_id'
  belongs_to :winner, :class_name => 'User', :foreign_key => 'winner_id'
  belongs_to :map

  has_many :players, :inverse_of => :game, :autosave => true, :dependent => :destroy
  has_many :development_cards, :inverse_of => :game, :autosave => true, :dependent => :destroy

  has_many :chats, :through => :players
  has_many :game_logs, :through => :players
  has_many :dice_rolls, :through => :players
  
  include GameBoard
  def game_board
    GameBoard.new(map, players)
  end

  def current_player
    players.find{|p| p.id == current_player_id}
  end

  def current_player=(player)
    self.current_player_id = player.id
  end

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

  def sorted_players
    @sorted_players ||= players.sort{|p1, p2| p1.turn_num <=> p2.turn_num}
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

  def advance?
    if waiting_for_players?
      false
    elsif placing_initial_pieces?
      advance_while_placing_initial_pieces?
    end
  end

  def process_dice_roll?(dice_num)
    if dice_num == 7
      return handle_seven_roll?
    end

    producing_hexes = map.hexes.select{|hex| hex.dice_num == dice_num && (hex.pos_x != robber_x || hex.pos_y != robber_y)}
    @resources_to_give = Hash.new

    producing_hexes.each do |hex|
      settlements = game_board.get_settlements_touching_hex(hex.pos_x, hex.pos_y)
      settlements.each do |settlement|
        if !@resources_to_give.has_key? settlement.player
          @resources_to_give[settlement.player] = Hash.new(0)
        end
        @resources_to_give[settlement.player][hex.resource_type] += (settlement.is_city ? 2 : 1)
      end
    end

    current_player.turn_status = PLAYING_TURN
    save
  end
  
  before_save do
    if @resources_to_give
      @resources_to_give.all?{|cur_player, resources| cur_player.collect_resources?(resources) }
    else
      true
    end
  end

  #when saving a game, initialize it for play if it's full but status is still waiting
  after_save do
    if num_players == players.length && waiting_for_players?
      raise ActiveRecord::Rollback unless init_game?
    end
    true
  end

  def player_finished_discarding?(player)
    player.turn_status = WAITING_FOR_TURN
    if !players.any?{|p| p.id != player.id && p.turn_status != WAITING_FOR_TURN}
      current_player.turn_status = MOVING_ROBBER
    end

    save
  end

  def player_moved_robber?(player, x, y)
    true
  end

  private
  def init_game?
    #give each player their own turn
    players.shuffle.each_with_index do |player, index|
      player.turn_num = index + 1
      player.turn_status = (index == 0 ? PLACING_INITIAL_SETTLEMENT : WAITING_FOR_TURN)
      player.resources.build(type: WHEAT)
      player.resources.build(type: WOOD)
      player.resources.build(type: WOOL)
      player.resources.build(type: ORE)
      player.resources.build(type: BRICK)
      player.resources.each do |resource|
        resource.count = 0
      end
    end

    self.current_player = players.find{|p| p.turn_num == 1}

    14.times { development_cards.build(type: KNIGHT) }
    5.times { development_cards.build(type: VICTORY_POINT) }
    2.times do
      development_cards.build(type: ROAD_BUILDING)
      development_cards.build(type: YEAR_OF_PLENTY)
      development_cards.build(type: MONOPOLY)
    end

    development_cards.shuffle.each_with_index { |card, index| card.position = index }

    self.status = STATUS_PLACING_INITIAL_PIECES
    save
  end

  def advance_while_placing_initial_pieces?
    if current_player.turn_status != PLACING_INITIAL_ROAD
      return false
    end

    if turn_num == 1 && current_player.turn_num != num_players
      next_player = players.find{|player| player.turn_num == current_player.turn_num + 1}
      next_player.turn_status = PLACING_INITIAL_SETTLEMENT
      current_player.turn_status = WAITING_FOR_TURN
      self.current_player = next_player
    elsif turn_num == 1
      self.turn_num = 2
      current_player.turn_status = PLACING_INITIAL_SETTLEMENT
    elsif turn_num == 2 && current_player.turn_num != 1
      next_player = players.find{|player| player.turn_num == current_player.turn_num - 1}
      next_player.turn_status = PLACING_INITIAL_SETTLEMENT
      current_player.turn_status = WAITING_FOR_TURN
      self.current_player = next_player
    elsif turn_num == 2
      self.turn_num = 3
      self.status = STATUS_PLAYING
      current_player.turn_status = READY_TO_ROLL
    else
      raise "There was an error"
    end
    save
  end

  def handle_seven_roll?
    need_discards = false

    players.each do |player|
      if player.get_resource_count > 7
        player.turn_status = DISCARDING_CARDS_DUE_TO_ROBBER
        need_discards = true
      elsif player == current_player
        current_player.turn_status = WAITING_FOR_TURN
      end
    end

    if !need_discards && current_player.turn_status == WAITING_FOR_TURN
      current_player.turn_status = MOVING_ROBBER
    end

    save
  end
end
