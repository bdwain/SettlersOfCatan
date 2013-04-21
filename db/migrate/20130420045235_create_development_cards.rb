class CreateDevelopmentCards < ActiveRecord::Migration
  def change
    create_table :development_cards do |t|
      t.references :player, :null => true
      t.references :game, :null => false
      t.integer :type, :null => false
      t.integer :position, :null => false
      t.boolean :was_used, :null => false, :default => false

      t.timestamps
    end
    add_index :development_cards, :player_id
    add_index :development_cards, :game_id
  end
end
