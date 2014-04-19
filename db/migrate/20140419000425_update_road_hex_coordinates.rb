class UpdateRoadHexCoordinates < ActiveRecord::Migration
  def change
    add_column :roads, :side, :integer, :null => false
  end
end
