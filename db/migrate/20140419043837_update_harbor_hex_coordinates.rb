class UpdateHarborHexCoordinates < ActiveRecord::Migration
  def change
    add_column :harbors, :side, :integer, :null => false
  end
end
