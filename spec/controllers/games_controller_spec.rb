require 'spec_helper'

describe GamesController do
  context "When Not Logged In" do
    let(:game) { FactoryGirl.build_stubbed(:game) }
    after { response.should redirect_to new_user_session_path }
    it { get :index }
    it { get :new }
    it { get :show, :id => game.to_param }
    it { post :create, :game => FactoryGirl.attributes_for(:game) }
    it { put :update, :id => game.to_param, :game => {'these' => 'params'} }
  end

  context "When Logged In" do
    login
    describe "GET index" do
      it "assigns all games as @games" do
        game = FactoryGirl.create(:game)
        game2 = FactoryGirl.create(:game)
        get :index
        assigns(:games).should eq([game, game2])
      end
    end

    describe "GET show" do
      it "assigns the requested game as @game" do
        game = FactoryGirl.create(:game)
        get :show, {:id => game.to_param}
        assigns(:game).should eq(game)
      end
    end

    describe "GET new" do
      it "assigns a new game as @game" do
        get :new
        assigns(:game).should be_a_new(Game)
      end
    end

    describe "POST create" do
      context "with valid params" do
        it "creates a new Game" do
          expect {
            post :create, {:game => FactoryGirl.attributes_for(:game)}
          }.to change(Game, :count).by(1)
        end

        it "assigns a newly created game as @game" do
          post :create, {:game => FactoryGirl.attributes_for(:game)}
          assigns(:game).should be_a(Game)
          assigns(:game).should be_persisted
        end

        it "sets the creator of game to the current_user" do
          post :create, {:game => FactoryGirl.attributes_for(:game)}
          assigns(:game).creator.should eq(@current_user)
        end

        it "redirects to the created game" do
          post :create, {:game => FactoryGirl.attributes_for(:game)}
          response.should redirect_to(Game.last)
        end
      end

      context "with invalid params" do
        before(:each) do
          Game.any_instance.stub(:save).and_return(false)
          post :create, {:game => {  }}
        end
        it "assigns a newly created but unsaved game as @game" do
          assigns(:game).should be_a_new(Game)
        end

        it "re-renders the 'new' template" do
          response.should render_template("new")
        end

        it "sets the flash" do
          should set_the_flash[:error].to("Something went wrong creating the game")
        end
      end
    end

    describe "PUT update" do
      #nothing yet
    end
  end
end
