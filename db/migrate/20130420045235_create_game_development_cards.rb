class CreateGameDevelopmentCards < ActiveRecord::Migration
  def change
    create_table :game_development_cards do |t|
      t.references :game_player, :null => true
      t.references :game, :null => true
      t.integer :card_type, :null => false
      t.integer :card_position, :null => false
      t.boolean :was_used, :null => false

      t.timestamps
    end
    add_index :game_development_cards, :game_player_id
    add_index :game_development_cards, :game_id
  end
end
