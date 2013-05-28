class PlayerSerializer < ActiveModel::Serializer
  attributes :id, :turn_num, :turn_status, :turn_deadline, 
             :resource_count, :unused_development_card_count
  has_many :development_cards, :settlements, :roads, :resources
  has_one :user

  def include_resources?
    current_user == object.user
  end

  def development_cards
    if current_user == object.user
      object.development_cards
    else
      object.development_cards.where(:was_used => true)
    end
  end

  def resource_count
    object.resources.count
  end

  def unused_development_card_count
    object.development_cards.where(:was_used => false).count
  end
end
