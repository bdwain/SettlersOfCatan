class GamesController < ApplicationController
  before_filter :authenticate_user!
  
  # GET /games
  def index
    @games = Game.all
  end

  # GET /games/1
  def show
    @game = Game.find(params[:id])
  end

  # GET /games/new
  def new
    @game = Game.new
  end

  # POST /games
  def create
    @game = Game.new(params[:game])
    if @game.valid?
      if @game.add_user?(current_user) && @game.save
        redirect_to @game and return
      else
        flash[:error] = "Something went wrong creating the game"
      end
    end

    #fallback
    render action: 'new'
  end

  # PUT /games/1
  def update
    #prob do something later
    redirect_to games_url
  end
end
