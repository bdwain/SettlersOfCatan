require 'spec_helper'

describe GamesController do
  context "When Not Logged In" do
    let(:game) { FactoryGirl.create(:game) }
    after { response.should redirect_to new_user_session_path }
    it { get :index }
    it { get :new }
    it { get :show, :id => game.to_param }
    it { get :edit, :id => game.to_param }
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

    describe "GET edit" do
      it "assigns the requested game as @game" do
        game = FactoryGirl.create(:game)
        get :edit, {:id => game.to_param}
        assigns(:game).should eq(game)
      end
    end

    describe "POST create" do
      describe "with valid params" do
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

        it "redirects to the created game" do
          post :create, {:game => FactoryGirl.attributes_for(:game)}
          response.should redirect_to(Game.last)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved game as @game" do
          # Trigger the behavior that occurs when invalid params are submitted
          Game.any_instance.stub(:save).and_return(false)
          post :create, {:game => {  }}
          assigns(:game).should be_a_new(Game)
        end

        it "re-renders the 'new' template" do
          # Trigger the behavior that occurs when invalid params are submitted
          Game.any_instance.stub(:save).and_return(false)
          post :create, {:game => {  }}
          response.should render_template("new")
        end
      end
    end

    describe "PUT update" do
      describe "with valid params" do
        it "updates the requested game" do
          game = FactoryGirl.create(:game)
          # Assuming there are no other games in the database, this
          # specifies that the Game created on the previous line
          # receives the :update_attributes message with whatever params are
          # submitted in the request.
          Game.any_instance.should_receive(:update_attributes).with({ "these" => "params" })
          put :update, {:id => game.to_param, :game => { "these" => "params" }}
        end

        it "assigns the requested game as @game" do
          game = FactoryGirl.create(:game)
          put :update, {:id => game.to_param, :game => FactoryGirl.attributes_for(:game)}
          assigns(:game).should eq(game)
        end

        it "redirects to the game" do
          game = FactoryGirl.create(:game)
          put :update, {:id => game.to_param, :game => FactoryGirl.attributes_for(:game)}
          response.should redirect_to(game)
        end
      end

      describe "with invalid params" do
        it "assigns the game as @game" do
          game = FactoryGirl.create(:game)
          # Trigger the behavior that occurs when invalid params are submitted
          Game.any_instance.stub(:save).and_return(false)
          put :update, {:id => game.to_param, :game => {  }}
          assigns(:game).should eq(game)
        end

        it "re-renders the 'edit' template" do
          game = FactoryGirl.create(:game)
          # Trigger the behavior that occurs when invalid params are submitted
          Game.any_instance.stub(:save).and_return(false)
          put :update, {:id => game.to_param, :game => {  }}
          response.should render_template("edit")
        end
      end
    end
  end
end
