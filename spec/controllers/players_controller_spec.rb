require 'spec_helper'

describe PlayersController do
  context "When Not Logged In" do
    let(:game) {FactoryGirl.build_stubbed(:game)}
    let(:player) {FactoryGirl.build_stubbed(:player)}
    after { expect(response).to redirect_to new_user_session_path }
    it { post :create, :game_id => game }
    it { delete :destroy, :id => player }
  end

  context "When Logged In" do
    login

    describe "POST create" do
      shared_examples "POST create failures" do
        it "redirects to the games index" do
          post :create, :game_id => game
          expect(response).to redirect_to(games_url)
        end

        it "flashes an error" do
          post :create, :game_id => game
          should set_the_flash[:error].to("You couldn't join the game")
        end
      end

      context "with valid input" do
        let(:game) {FactoryGirl.build_stubbed(:game)}
        before(:each) { expect(Game).to receive(:find_by_id).and_return(game) }

        context "on success" do          
          it "redirects to the game with valid input" do
            expect(game).to receive(:add_user?).with(@current_user).and_return(true)            
            post :create, :game_id => game
            expect(response).to redirect_to(game)
          end
        end

        context "when add_user? returns false" do
          before(:each) { allow(game).to receive(:add_user?).and_return(false) }
          include_examples "POST create failures"
        end
      end

      context "with a nil game" do
        let(:game) {nil}
        include_examples "POST create failures"
      end
    end

    describe "DELETE destroy" do
      shared_examples "destroy redirects to games_url" do
        it "redirects to games_url" do
          delete :destroy, {:id => player}
          expect(response).to redirect_to(games_url)
        end
      end

      shared_examples "destroy sets the flash" do |flash_msg|
        it "sets the flash" do
          delete :destroy, {:id => player}
          should set_the_flash[:error].to(flash_msg)
        end
      end

      let(:player) { FactoryGirl.build_stubbed(:player) }
      context "with a valid player id" do
        before(:each) { allow(Player).to receive(:find_by_id).and_return(player) }
        context "owned by the current user" do
          before(:each) { expect(player).to receive(:user).at_least(:once).and_return(@current_user) }

          context "when remove_player? returns true" do
            before(:each) { expect(player.game).to receive(:remove_player?).with(player).and_return(true) }

            include_examples "destroy redirects to games_url"
            
            it "doesn't set the flash" do
              delete :destroy, {:id => player.id}
              should_not set_the_flash
            end
          end

          context "when remove_player? returns false" do
            before(:each) { allow(player.game).to receive(:remove_player?).and_return(false) }

            include_examples "destroy redirects to games_url"
            include_examples "destroy sets the flash", "The game already started. You can't quit now"
          end
        end

        context "not owned by the current user" do
          let(:other_user) { FactoryGirl.build_stubbed(:confirmed_user) }
          before(:each) do
            allow(player).to receive(:user).and_return(other_user)
            expect_any_instance_of(Player).to_not receive(:remove_player?)
          end

          include_examples "destroy redirects to games_url"
          include_examples "destroy sets the flash", "You can't do that"
        end
      end

      context "with an invlaid player id" do
        before(:each) { expect_any_instance_of(Game).to_not receive(:remove_player?) }

        include_examples "destroy redirects to games_url"
        include_examples "destroy sets the flash", "Invalid request"
      end
    end
  end
end
