class HexSerializer < ActiveModel::Serializer
  attributes :id, :dice_num, :resource_type, :pos_x, :pos_y
end
