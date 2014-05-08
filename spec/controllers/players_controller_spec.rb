require 'spec_helper'

describe PlayersController do
  context "When Not Logged In" do
    let(:game) {FactoryGirl.build_stubbed(:game)}
    let(:player) {FactoryGirl.build_stubbed(:player)}
    after { expect(response).to redirect_to new_user_session_path }
    it { post :create, :game_id => game }
    it { delete :destroy, :id => player }
    it { post :choose_robber_victim, :player_id => player}
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

      context "with an invalid game game" do
        let(:game) {FactoryGirl.build_stubbed(:game, id: -1)}

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

    describe "POST choose_robber_victim" do

      shared_examples "redirecs to games index" do
        it "redirects to the games index" do
          post :choose_robber_victim, :player_id => player_id, :victim_id => victim_id
          expect(response).to redirect_to(games_url)
        end
      end

      context "with an invalid player" do
        let(:player_id) {-1}
        let(:victim_id) {1}

        include_examples "redirecs to games index"
      end

      context "with a valid player" do
        let(:game) {FactoryGirl.build_stubbed(:game)}
        let(:player) {FactoryGirl.build_stubbed(:in_game_player, {game: game})}
        let(:player_id) {player.id}
        before(:each) { allow(player).to receive(:game).and_return(game) }
        before(:each) { allow(Player).to receive(:find_by_id).with(player_id.to_s).and_return(player) }

        context "with an invalid vicitm" do
          let(:victim_id) {-1}
          before(:each) { allow(Player).to receive(:find_by_id).with(victim_id.to_s).and_return(nil) }

          include_examples "redirecs to games index"
        end

        context "with a valid vicitim" do
          let(:victim) {FactoryGirl.build_stubbed(:in_game_player, {game: game})}
          let(:victim_id) {victim.id}
          before(:each) { allow(Player).to receive(:find_by_id).with(victim.id.to_s).and_return(victim) }

          context "when the current_user does not control the player" do
            let(:other_user) { FactoryGirl.build_stubbed(:confirmed_user) }
            before(:each) {allow(player).to receive(:user).and_return(other_user)}

            include_examples "redirecs to games index"
          end

          context "when the current_user does control the player" do
            before(:each) {allow(player).to receive(:user).and_return(@current_user)}

            context "when player.choose_robber_victim? returns true" do
              before(:each) do
                allow(player).to receive(:choose_robber_victim?).and_return(true)
                post :choose_robber_victim, :player_id => player, :victim_id => victim
              end

              it "redirects to the game" do
                expect(response).to redirect_to(game)
              end
            end

            context "when player.choose_robber_victim? returns false" do
              before(:each) do
                allow(player).to receive(:choose_robber_victim?).and_return(false)
                post :choose_robber_victim, :player_id => player, :victim_id => victim
              end

              it "redirects to the game" do
                expect(response).to redirect_to(game)
              end

              it "flashes an error message" do
                should set_the_flash[:error].to("There was a problem choosing the robber victim")
              end
            end
          end
        end
      end
    end
  end
end
