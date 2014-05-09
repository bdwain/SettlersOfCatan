class DevelopmentCardsController < ApplicationController
  before_filter :authenticate_user!

  # POST /player/:player_id/development_cards
  def create
    player = Player.find_by_id(params[:player_id])
    if player == nil || player.user != current_user
      redirect_to games_url
    elsif player.buy_development_card?
      redirect_to player.game
    else
      redirect_to player.game, :flash => { :error => "There was a problem buying the development card" }
    end
  end
end
