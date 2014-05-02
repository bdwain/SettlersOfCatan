require 'spec_helper'

describe GamesController do
  context "When Not Logged In" do
    let(:game) { FactoryGirl.build_stubbed(:game) }
    after { response.should redirect_to new_user_session_path }
    it { get :index }
    it { get :new }
    it { get :show, :id => game.to_param }
    it { post :create, :game => FactoryGirl.attributes_for(:game) }
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
        let(:params) {{:game => {:num_players => 3}}}
        it "creates a new Game" do
          expect {
            post :create, params
          }.to change(Game, :count).by(1)
        end

        it "assigns a newly created game as @game" do
          post :create, params
          assigns(:game).should be_a(Game)
          assigns(:game).should be_persisted
        end

        it "sets the creator of game to the current_user" do
          post :create, params
          assigns(:game).creator.should eq(@current_user)
        end

        it "redirects to the created game" do
          post :create, params
          response.should redirect_to(Game.last)
        end
      end

      context "with params not in the game hash" do
        it "throws a ParameterMissing exception" do
          expect{
            post :create, {:foo => { :num_players => 3 }}
          }.to raise_exception(ActionController::ParameterMissing)
        end
      end

      context "with invalid params" do
        before(:each) {post :create, {:game => { :foo => 1 }}}

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

      context "with empty params" do
        it "throws a ParameterMissing exception" do
          expect{
            post :create, {:game => { }}
          }.to raise_exception(ActionController::ParameterMissing)
        end
      end
    end
  end
end
