class GameSerializer < ActiveModel::Serializer
  attributes :id, :status, :num_players, :robber_x, :robber_y, 
      :development_cards_count, :turn_num, :updated_at
  has_one :map, :winner, :creator
  has_many :players, :chats, :game_logs

  def development_cards_count
    object.development_cards.where(:player_id => nil).count
  end

  def game_logs
    current_player_id = players.where(:user_id => current_user.id).first.id
    object.game_logs.where("is_private = false OR target_id = #{current_player_id}")
  end
end
