class GamesController < ApplicationController
  before_filter :authenticate_user!
  
  # GET /games
  def index
    @games = Game.all
  end

  # GET /games/:id
  def show
    @game = Game.find(params[:id])
  end

  # GET /games/new
  def new
    @game = Game.new
  end

  # POST /games
  def create
    @game = Game.new(game_params)
    @game.creator = current_user
    if @game.save
      redirect_to @game
    else
      flash[:error] = "Something went wrong creating the game"
      render action: 'new'      
    end
  end

  #PUT /games/:game_id/robber
  def move_robber
    game = Game.find_by_id(params[:game_id])

    if game == nil
      redirect_to games_url
    elsif game.move_robber?(game.player(current_user), params[:robber_x].to_i, params[:robber_y].to_i)
      redirect_to game
    else
      redirect_to game, :flash => { :error => "There was an error moving the robber" }
    end
  end

  private
  def game_params
    params.require(:game).permit(:num_players)
  end
end
