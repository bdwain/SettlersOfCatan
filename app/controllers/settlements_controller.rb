class SettlementsController < ApplicationController
  before_filter :authenticate_user!

  # POST /player/:player_id/settlements
  def create
    player = Player.find_by_id(params[:player_id])
    if player == nil || player.user != current_user
      redirect_to games_url
    elsif player.add_settlement?(params[:vertex_x].to_i, params[:vertex_y].to_i, params[:side].to_i)
      redirect_to player.game
    else
      redirect_to player.game, :flash => { :error => "There was a problem adding the settlement" }
    end
  end
end