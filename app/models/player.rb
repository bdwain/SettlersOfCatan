class Player < ActiveRecord::Base
  belongs_to :game, :inverse_of => :players
  belongs_to :user, :inverse_of => :players
  has_many :resources, :inverse_of => :player, :autosave => true, :dependent => :destroy
  has_many :development_cards, :inverse_of => :player, :autosave => true, :dependent => :destroy
  has_many :settlements, :inverse_of => :player, :autosave => true, :dependent => :destroy
  has_many :roads, :inverse_of => :player, :autosave => true, :dependent => :destroy
  has_many :chats, :inverse_of => :sender, :autosave => true, :dependent => :destroy, :foreign_key => 'sender_id'
  has_many :game_logs, :inverse_of => :current_player, :autosave => true, :dependent => :destroy, :foreign_key => 'current_player_id'
  has_many :dice_rolls, :inverse_of => :current_player, :autosave => true, :dependent => :destroy, :foreign_key => 'current_player_id'

  validates_presence_of :game, :user
  validates_uniqueness_of :user_id, :scope => :game_id
  
  validates :turn_num, :presence => true, :inclusion => { :in => 1.upto(4) },
            :numericality => {:only_integer => true }

  validates :turn_status, :presence => true, 
            :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
  
  def add_settlement?(x, y, side)
    if !game.game_board.vertex_is_free_for_building?(x, y, side)
      return false
    elsif turn_status != PLACING_INITIAL_SETTLEMENT # later make sure they're not buying either
      return false
    end

    game_log = game_logs.build
    game_log.turn_num = game.turn_num
    game_log.msg = "#{user.displayname} placed a settlement on (#{x},#{y},#{side})"
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

    game_log = game_logs.build
    game_log.turn_num = game.turn_num
    game_log.msg = "#{user.displayname} placed a road on (#{x},#{y},#{side})"
    roads.build(:edge_x => x, :edge_y => y, :side => side)

    return false unless turn_status != PLACING_INITIAL_ROAD || game.advance?
    save
  end
end
