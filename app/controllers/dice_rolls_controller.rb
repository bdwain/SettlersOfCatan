class DiceRollsController < ApplicationController
  before_filter :authenticate_user!

  # POST /dice_rolls
  def create
    player = Player.find_by_id(params[:player_id])
    if player == nil || player.user != current_user
      redirect_to games_url
    elsif player.roll_dice?
      redirect_to player.game
    else
      redirect_to player.game, :flash => { :error => "There was a problem rolling the dice" }
    end
  end
end
