class ResourcesController < ApplicationController
  before_filter :authenticate_user!
  
  # PATCH /resources
  def update_multiple
    player = Player.find_by_id(params[:player_id])

    if params[:delete]
      deleteParams = Hash.new
      params[:delete].each_pair do |type_str, amt_to_discard|
        deleteParams[type_str.to_i] = amt_to_discard.to_i
      end
    end

    if player == nil || player.user != current_user
      redirect_to games_url
    elsif player.discard_half_resources?(deleteParams)
      redirect_to player.game
    else
      redirect_to player.game, :flash => { :error => "There was a problem discarding the resources" }
    end
  end
end
