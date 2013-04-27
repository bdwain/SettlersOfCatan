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
      shared_examples "create failures" do
        it "redirects to the games index" do
          post :create, {:game => game}
          response.should redirect_to(games_url)
        end

        it "sets the flash" do
          post :create, {:game => game}
          should set_the_flash.to("You couldn't join the game")
        end
      end

      context "with valid game id" do
        let(:game) {FactoryGirl.create(:game)}

        context "adding the player is successful" do
          before(:each) do
            Game.any_instance.should_receive(:add_user?).with(@current_user).and_return(true)
          end

          it "redirects to the game" do
            post :create, {:game => game}
            response.should redirect_to(game)
          end

          it "doesn't set the flash" do
            post :create, {:game => game}
            should_not set_the_flash
          end

        end

        context "adding the player fails" do
          before(:each) do
            Game.any_instance.stub(:add_user?).and_return(false)
          end

          include_examples "create failures"
        end
      end

      context "with invalid game id" do
        let(:game) { nil }
        before(:each) do
          Game.any_instance.should_not_receive(:add_user?)
        end

          include_examples "create failures"
      end
    end

    describe "DELETE destroy" do
      before(:each) do
        @player = FactoryGirl.create(:player)
      end

      shared_examples "destroy redirects to games_url" do
        it "redirects to games_url" do
          delete :destroy, {:id => @player.id}
          response.should redirect_to(games_url)
        end
      end

      shared_examples "destroy sets the flash" do |flash_msg|
        it "sets the flash" do
          delete :destroy, {:id => @player.id}
          should set_the_flash[:error].to(flash_msg)
        end
      end

      context "with a valid player id" do
        context "owned by the current user" do
          before(:each) do
            Player.should_receive(:find_by_id).with(@player.to_param).and_return(@player)
            @player.should_receive(:user).at_least(:once).and_return(@current_user)
          end

          context "when remove_player? returns true" do
            before(:each) do
              @player.game.should_receive(:remove_player?).with(@player).and_return(true)
            end

            include_examples "destroy redirects to games_url"
            
            it "doesn't set the flash" do
              delete :destroy, {:id => @player.id}
              should_not set_the_flash
            end
          end

          context "when remove_player? returns false" do
            before(:each) do
              @player.game.stub(:remove_player?).and_return(false)
            end

            include_examples "destroy redirects to games_url"
            include_examples "destroy sets the flash", "The game already started. You can't quit now"
          end
        end

        context "not owned by the current user" do
          before(:each) do
            @player.stub(:user).and_return(nil)
            @player.stub(:valid?).and_return(true)
            @player.game.should_not_receive(:remove_player?)
          end

          include_examples "destroy redirects to games_url"
          include_examples "destroy sets the flash", "You can't do that"
        end
      end

      context "with an invlaid player id" do
        before(:each) do
          Player.stub(:find_by_id).and_return(nil)
          Game.any_instance.should_not_receive(:remove_player?)
        end

        include_examples "destroy redirects to games_url"
        include_examples "destroy sets the flash", "Invalid request"
      end
    end
  end
end
