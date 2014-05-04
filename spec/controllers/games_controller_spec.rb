require 'spec_helper'

describe GamesController do
  context "When Not Logged In" do
    let(:game) { FactoryGirl.build_stubbed(:game) }
    after { expect(response).to redirect_to new_user_session_path }
    it { get :index }
    it { get :new }
    it { get :show, :id => game.to_param }
    it { post :create, :game => FactoryGirl.attributes_for(:game) }
    it { put :move_robber, :game_id => game}
  end

  context "When Logged In" do
    login
    describe "GET index" do
      it "assigns all games as @games" do
        game = FactoryGirl.create(:game)
        game2 = FactoryGirl.create(:game)
        get :index
        expect(assigns(:games)).to eq([game, game2])
      end
    end

    describe "GET show" do
      it "assigns the requested game as @game" do
        game = FactoryGirl.create(:game)
        get :show, {:id => game.to_param}
        expect(assigns(:game)).to eq(game)
      end
    end

    describe "GET new" do
      it "assigns a new game as @game" do
        get :new
        expect(assigns(:game)).to be_a_new(Game)
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
          expect(assigns(:game)).to be_a(Game)
          expect(assigns(:game)).to be_persisted
        end

        it "sets the creator of game to the current_user" do
          post :create, params
          expect(assigns(:game).creator).to eq(@current_user)
        end

        it "redirects to the created game" do
          post :create, params
          expect(response).to redirect_to(Game.last)
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
          expect(assigns(:game)).to be_a_new(Game)
        end

        it "re-renders the 'new' template" do
          expect(response).to render_template("new")
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

    describe "PUT move_robber" do
      context "with an invalid game" do
        before(:each) { allow(Game).to receive(:find_by_id).and_return(nil) }

        it "redirects to the games index" do
          put :move_robber, :game_id => -1, :robber_x => "1", :robber_y => "1"
          expect(response).to redirect_to(games_url)
        end
      end

      context "with a valid game" do
        let(:game) {FactoryGirl.build_stubbed(:game)}
        let(:player) {double("Player")}
        let(:move_robber_retval) {true}
        before(:each) do
          allow(Game).to receive(:find_by_id).and_return(game)
          allow(game).to receive(:player).and_return(player)
          allow(game).to receive(:move_robber?).and_return(move_robber_retval)
          put :move_robber, :game_id => game, :robber_x => "2", :robber_y => "3"
        end

        it "calls game.player with current_user" do
          expect(game).to have_received(:player).with(@current_user)
        end

        it "calls game.move_robber? with the result of game.player and the params as ints" do
          expect(game).to have_received(:move_robber?).with(player, 2, 3)
        end

        context "when game.move_robber? returns true" do
          it "redirects you to the game" do
            expect(response).to redirect_to(game)
          end

          it "does not set the flash" do
            should_not set_the_flash
          end
        end

        context "when game.move_robber? returns false" do
          let(:move_robber_retval) {false}

          it "redirects you to the game" do
            expect(response).to redirect_to(game)
          end

          it "should set the flash to say that moving the robber failed" do
            should set_the_flash[:error].to("There was an error moving the robber")
          end
        end
      end
    end
  end
end
