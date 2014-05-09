class Player < ActiveRecord::Base
  belongs_to :game, :inverse_of => :players
  belongs_to :user, :inverse_of => :players
  has_many :resources, :inverse_of => :player, :autosave => true, :dependent => :destroy
  has_many :development_cards, :inverse_of => :player, :autosave => true, :dependent => :destroy
  has_many :settlements, :inverse_of => :player, :autosave => true, :dependent => :destroy
  has_many :roads, :inverse_of => :player, :autosave => true, :dependent => :destroy
  has_many :chats, :inverse_of => :sender, :autosave => true, :dependent => :destroy, :foreign_key => 'sender_id'
  has_many :game_logs, :inverse_of => :target, :autosave => true, :dependent => :destroy, :foreign_key => 'target_id'
  has_many :dice_rolls, :inverse_of => :current_player, :autosave => true, :dependent => :destroy, :foreign_key => 'current_player_id'

  validates_presence_of :game, :user
  validates_uniqueness_of :user_id, :scope => :game_id
  
  validates :turn_num, :presence => true, :inclusion => { :in => 1.upto(4) },
            :numericality => {:only_integer => true }

  validates :turn_status, :presence => true, 
            :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
  
  def get_resource_count
    resources.inject(0) {|sum, resource| sum + resource.count}
  end

  def add_settlement?(x, y, side)
    if !game.game_board.vertex_is_free_for_building?(x, y, side)
      return false
    end

    msg = "#{user.displayname} "

    case turn_status
    when PLACING_INITIAL_SETTLEMENT
      msg << "placed a settlement on "
      if game.turn_num == 2
        game.game_board.get_hexes_from_vertex(x,y,side).each do |hex|
          if hex.resource_type != DESERT
            resource = get_resource(hex.resource_type)
            resource.count += 1
          end
        end
      end
      self.turn_status = PLACING_INITIAL_ROAD
    when PLAYING_TURN
      if !game.game_board.vertex_is_connected_to_player?(x, y, side, self)
        return false
      end
      msg << "bought a settlement on "
      wheat = get_resource(WHEAT)
      wood = get_resource(WOOD)
      wool = get_resource(WOOL)
      brick = get_resource(BRICK)

      if wheat.count == 0 || wool.count == 0 || wood.count == 0 || brick.count == 0
        return false
      end

      wheat.count -= 1
      wool.count -= 1
      wood.count -= 1
      brick.count -= 1
    else
      return false
    end

    msg << "(#{x},#{y},#{side})"

    build_game_log(msg)
    settlements.build(:vertex_x => x, :vertex_y => y, :side => side)
    
    save
  end

  def add_road?(x, y, side)
    last_settlement = settlements.last
    if !game.game_board.edge_is_free_for_building_by_player?(x, y, side, self)
      return false
    elsif turn_status != PLACING_INITIAL_ROAD # later make sure they're not buying either
      return false
    elsif !game.game_board.edge_is_connected_to_vertex?(x, y, side, last_settlement.vertex_x, last_settlement.vertex_y, last_settlement.side)
      return false
    end

    build_game_log("#{user.displayname} placed a road on (#{x},#{y},#{side})")
    roads.build(:edge_x => x, :edge_y => y, :side => side)

    return false unless turn_status != PLACING_INITIAL_ROAD || game.advance?
    save
  end

  def roll_dice?
    if turn_status != READY_TO_ROLL
      return false
    end

    die_1 = 1 + rand(6)
    die_2 = 1 + rand(6)
    build_game_log("#{user.displayname} rolled a (#{die_1 + die_2})")
    dice_roll = dice_rolls.build(:turn_num => game.turn_num, :die_1 => die_1, :die_2 => die_2)

    return false unless game.process_dice_roll?(die_1 + die_2)
    save
  end

  def collect_resources?(resources_gained)
    if resources_gained.empty?
      return true
    end

    msg = "#{user.displayname} got "

    resources_gained.each_with_index do |keyval, index|
      resource = get_resource(keyval[0])
      resource.count += keyval[1]
      
      if index != 0
        msg << " and "
      end

      msg << "#{keyval[1]} #{resource.name}"
    end

    build_game_log(msg)
    save
  end

  def discard_half_resources?(resources_to_discard)
    if turn_status != DISCARDING_CARDS_DUE_TO_ROBBER
      return false
    end

    num_discarded = 0
    amount_needed_to_discard = get_resource_count/2

    msg = "#{user.displayname} discarded "
    start_using_and_in_msg = false
    resources_to_discard.each_with_index do |keyval, index|
      resource = get_resource(keyval[0])
      resource.count -= keyval[1]
      num_discarded += keyval[1]

      next if keyval[1] == 0 #don't log that they discarded 0 of something

      if index != 0 && start_using_and_in_msg
        msg << " and "
      end

      msg << "#{keyval[1]} #{resource.name}"
      start_using_and_in_msg = true
    end

    if num_discarded != amount_needed_to_discard
      return false
    end

    build_game_log(msg)

    return false unless game.player_finished_discarding?(self)
    save
  end

  def resources_stolen(num)
    return {} if num == 0 || get_resource_count == 0
    resource_array = Array.new
    resources.each do |resource|
      resource.count.times do
        resource_array << resource.type
      end
    end

    msg = ""
    types_to_lose = Hash[resource_array.sample(num).group_by {|x| x}.map {|k,v| [k,v.count]}]

    types_to_lose.each_with_index do |keyval, index|
      resource = get_resource(keyval[0])
      resource.count -= keyval[1]

      if index != 0
        msg << " and "
      end

      msg << "#{keyval[1]} #{resource.name}"
    end

    if num == 1 || (types_to_lose.count == 1 && types_to_lose.first[1] == 1)
      msg << " was stolen"
    else
      msg << " were stolen"
    end


    build_game_log(msg, true)

    raise "resources_stolen_error" unless save
    types_to_lose
  end

  def move_robber?(x, y)
    if turn_status != MOVING_ROBBER
      return false
    end

    build_game_log("#{user.displayname} moved the robber")

    other_player_settlements = game.game_board.get_settlements_touching_hex(x, y).reject{|s| s.player == self}

    @robber_x = x
    @robber_y = y

    if other_player_settlements.count == 0
      self.turn_status = PLAYING_TURN
    elsif other_player_settlements.all?{|s| s.player == other_player_settlements.first.player}
      @player_to_rob = other_player_settlements.first.player
      self.turn_status = PLAYING_TURN
    else
      self.turn_status = CHOOSING_ROBBER_VICTIM
    end

    save
  end

  def choose_robber_victim?(victim)
    if turn_status != CHOOSING_ROBBER_VICTIM || !game.game_board.get_settlements_touching_hex(game.robber_x, game.robber_y).any?{|s| s.player == victim}
      return false
    end

    @player_to_rob = victim
    self.turn_status = PLAYING_TURN
    save
  end

  before_save :rob_players
  before_save :move_robber

  private
  def get_resource(type)
    resources.find{|r| r.type == type}
  end

  def build_game_log(msg, is_private = false)
    game_logs.build(:turn_num => game.turn_num, :current_player => game.current_player, :msg => msg, :is_private => is_private)
  end

  def move_robber
    if @robber_x && @robber_y
      x = @robber_x
      y = @robber_y
      @robber_x = nil
      @robber_y = nil
      game.move_robber?(x,y)
    else
      true
    end
  end

  def rob_players
    if @player_to_rob
      res = steal_resources_from?(@player_to_rob, 1)
      @player_to_rob = nil
      res
    else
      true
    end
  end

  def steal_resources_from?(victim, num_to_steal)
    if victim.game != game || victim == self
      return false
    end

    begin
      new_resource_counts = victim.resources_stolen(num_to_steal)
    rescue RuntimeError => e
      if e.to_s != "resources_stolen_error"
        raise e
      end
      return false
    end

    build_game_log("#{user.displayname} stole #{new_resource_counts.count} resources from #{victim.user.displayname}")

    if new_resource_counts.count != 0
      msg = "You stole "
      new_resource_counts.each_with_index do |keyval, index|
        resource = get_resource(keyval[0])
        resource.count += keyval[1]

        if index != 0
          msg << "and "
        end

        msg << "#{keyval[1]} #{resource.name} "
      end

      msg << "from #{victim.user.displayname}"

      build_game_log(msg, true)
      true
    end
  end
end
