class RestrictWhenDevelopmentCardsPlayed < ActiveRecord::Migration
  def change
    remove_column :development_cards, :was_used
    add_column :development_cards, :turn_bought, :integer, :null => true
    add_column :development_cards, :turn_used, :integer, :null => true
  end
end
