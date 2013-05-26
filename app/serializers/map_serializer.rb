class MapSerializer < ActiveModel::Serializer
  attributes :id, :name, :middle_row_width, :num_middle_rows, :num_rows
  has_many :hexes, :harbors
end
