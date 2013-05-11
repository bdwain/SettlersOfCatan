class CreateMaps < ActiveRecord::Migration
  def change
    create_table :maps do |t|
      t.string :name, :null => false, :limit => 50
      t.integer :middle_row_width, :null => false, :default => 5
      t.integer :num_rows, :null => false, :default => 5
      t.integer :num_middle_rows, :null => false, :default => 1

      t.timestamps
    end
  end
end
