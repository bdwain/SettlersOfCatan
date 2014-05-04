class PlayersController < ApplicationController
  before_filter :authenticate_user!

  # POST /game/:game_id/players
  def create
    game = Game.find_by_id(params[:game_id])
    if game != nil && game.add_user?(current_user)
      redirect_to game
    else
      redirect_to games_url, :flash => { :error => "You couldn't join the game" }
    end
  end

  # DELETE /players/:id
  def destroy
    player = Player.find_by_id(params[:id])
    if !player
      flash[:error] = "Invalid request"
    elsif player.user != current_user
      flash[:error] = "You can't do that"
    elsif !player.game.remove_player?(player)
      flash[:error] = "The game already started. You can't quit now"
    end
    redirect_to games_url
  end
end
