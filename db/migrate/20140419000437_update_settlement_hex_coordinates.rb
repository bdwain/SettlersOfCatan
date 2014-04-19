class UpdateSettlementHexCoordinates < ActiveRecord::Migration
  def change
    add_column :settlements, :side, :integer, :null => false
  end
end
