class PlayersController < ApplicationController
  before_filter :authenticate_user!

  # POST /players
  def create
    game = Game.find_by_id(params[:game_id])
    if game != nil && game.add_user?(current_user)
      redirect_to game
    else
      redirect_to games_url, :flash => { :error => "You couldn't join the game" }
    end
  end

  # DELETE /players/1
  def destroy
    player = Player.find_by_id(params[:id])
    if player != nil && player.user == current_user && player.game.remove_player?(player)
      redirect_to games_url
    elsif player != nil && player.user == current_user
      redirect_to games_url, :flash => { :error => "The game already started. You can't quit now" }
    elsif player != nil
      redirect_to games_url, :flash => { :error => "You can't do that" }
    else
      redirect_to games_url, :flash => { :error => "Invalid request" }
    end
  end
end
