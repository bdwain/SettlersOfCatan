require 'spec_helper'

describe PlayersController do
  context "When Not Logged In" do
    let(:game) { FactoryGirl.create(:partially_filled_game) }
    let(:player) {game.players.first}
    after { response.should redirect_to new_user_session_path }
    it { post :create, :game => game.id }
    it { delete :destroy, :id => player.to_param }
  end

  context "When Logged In" do
    login

    describe "POST create" do
      let(:mock_game_id) {1234}      
      
      shared_examples "create redirects to games_url" do
        it "redirects to games_url" do
          post :create, {:game => mock_game_id}
          response.should redirect_to(games_url)
        end
      end

      shared_examples "create sets the flash" do
        it "sets the flash" do
          post :create, {:game => mock_game_id}
          should set_the_flash.to('You couldn\'t join the game')
        end
      end

      context "with valid game id" do
        before(:each) do
          @game = double("game")
          Game.should_receive(:find_by_id).with(mock_game_id.to_s).and_return { @game }
        end

        context "adding the player is successful" do
          before(:each) do
            @game.should_receive(:add_user?).with(@current_user).and_return(true)
          end

          include_examples "create redirects to games_url"

          it "doesn't set the flash" do
            post :create, {:game => mock_game_id}
            should_not set_the_flash
          end

        end

        context "adding the player fails" do
          before(:each) do
            @game.should_receive(:add_user?).with(@current_user).and_return(false)
          end

          include_examples "create redirects to games_url"
          include_examples "create sets the flash"
        end
      end

      context "with invalid game id" do
        before(:each) do
          @game = double("game")
          Game.should_receive(:find_by_id).and_return { nil }
          @game.should_not_receive(:add_user?)
        end

        include_examples "create redirects to games_url"
        include_examples "create sets the flash"
      end
    end

    describe "DELETE destroy" do
      let(:mock_player_id) {1234}

      shared_examples "destroy redirects to games_url" do
        it "redirects to games_url" do
          delete :destroy, {:id => mock_player_id}
          response.should redirect_to(games_url)
        end
      end

      shared_examples "destroy sets the flash" do |flash_msg|
        it "sets the flash" do
          delete :destroy, {:id => mock_player_id}
          should set_the_flash[:error].to(flash_msg)
        end
      end

      context "with a valid player id" do
        before(:each) do
          @player = double("player")
          Player.should_receive(:find_by_id).with(mock_player_id.to_s).and_return { @player }
        end

        context "owned by the current user" do
          before(:each) do
            fakeUser = double("user")
            @player.should_receive(:user).at_least(:once).and_return(@current_user)
          end

          context "when remove_player? returns true" do
            before(:each) do
              fakeGame = double("game")
              @player.should_receive(:game).and_return(fakeGame)
              fakeGame.should_receive(:remove_player?).with(@player).and_return(true)
            end

            include_examples "destroy redirects to games_url"
            
            it "doesn't set the flash" do
              delete :destroy, {:id => mock_player_id}
              should_not set_the_flash
            end
          end

          context "when remove_player? returns false" do
            before(:each) do
              fakeGame = double("game")
              @player.should_receive(:game).and_return(fakeGame)
              fakeGame.should_receive(:remove_player?).with(@player).and_return(false)
            end

            include_examples "destroy redirects to games_url"
            include_examples "destroy sets the flash", "The game already started. You can't quit now"
          end
        end

        context "not owned by the current user" do
          before(:each) do
            fakeUser = double("user")
            @player.should_receive(:user).at_least(:once).and_return(fakeUser)
          end

          include_examples "destroy redirects to games_url"
          include_examples "destroy sets the flash", "You can't do that"
        end
      end

      context "with an invlaid player id" do
        before(:each) do
          @player = double("player")
          Player.should_receive(:find_by_id).and_return { nil }
        end

        include_examples "destroy redirects to games_url"
        include_examples "destroy sets the flash", "Invalid request"
      end
    end
  end
end
