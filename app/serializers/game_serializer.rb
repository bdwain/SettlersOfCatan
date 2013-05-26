class GameSerializer < ActiveModel::Serializer
  attributes :id, :status, :num_players, :robber_x, :robber_y, :development_cards_count, :updated_at
  has_one :map, :winner, :creator
  has_many :players

  def development_cards_count
    object.development_cards.where(:player_id => nil).count
  end
end
