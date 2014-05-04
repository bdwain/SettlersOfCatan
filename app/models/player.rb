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
    elsif turn_status != PLACING_INITIAL_SETTLEMENT # later make sure they're not buying either
      return false
    end

    build_game_log("#{user.displayname} placed a settlement on (#{x},#{y},#{side})")
    settlements.build(:vertex_x => x, :vertex_y => y, :side => side)

    if turn_status == PLACING_INITIAL_SETTLEMENT && game.turn_num == 2
      game.game_board.get_hexes_from_vertex(x,y,side).each do |hex|
        if hex.resource_type != DESERT
          resource = resources.find{|r| r.type == hex.resource_type}
          resource.count += 1
        end
      end
    end

    self.turn_status = PLACING_INITIAL_ROAD
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
      resource = resources.find{|r| r.type == keyval[0]}
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
      resource = resources.find{|r| r.type == keyval[0]}
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

  def move_robber?(x, y)
    if turn_status != MOVING_ROBBER || !game.game_board.hex_is_on_board?(x,y)
      return false
    end

    build_game_log("#{user.displayname} moved the robber")

    return false unless game.player_moved_robber?(self,x,y)
    save
  end

  private
  def build_game_log(msg)
    game_logs.build(:turn_num => game.turn_num, :current_player => game.current_player, :msg => msg)
  end
end
