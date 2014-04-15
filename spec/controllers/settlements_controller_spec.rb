require 'spec_helper'

describe SettlementsController do
  context "When Not Logged In" do
    let(:game) {FactoryGirl.build_stubbed(:game)}
    let(:player) {FactoryGirl.build_stubbed(:player)}
    after { response.should redirect_to new_user_session_path }
    it { post :create, :player_id => player, :vertex_x => 1, :vertex_y => 1 }
  end

  context "When Logged In" do
    login
    describe "POST create" do
      context "with an invalid player" do
        before(:each) { Player.should_receive(:find_by_id).and_return(nil) }
        it "redirects to the games index" do
          post :create, :player_id => -1, :vertex_x => 1, :vertex_y => 1
          response.should redirect_to(games_url)
        end
      end

      context "with a valid player" do
        let(:game) {FactoryGirl.build_stubbed(:game)}
        let(:player) {FactoryGirl.build_stubbed(:player)}
        before(:each) {player.stub(:game).and_return(game)}
        before(:each) { Player.should_receive(:find_by_id).with(player.id.to_s).and_return(player) }

        context "when the current_user does control the player" do
          before(:each) {player.stub(:user).and_return(@current_user)}
          context "when player.add_settlement? returns true" do
            before(:each) do
              player.stub(:add_settlement?).and_return(true)
              post :create, :player_id => player, :vertex_x => 1, :vertex_y => 1
            end

            it "redirects to the game" do
              response.should redirect_to(game)
            end
          end

          context "when player.add_settlement? returns false" do
            before(:each) do
              player.stub(:add_settlement?).and_return(false)
              post :create, :player_id => player, :vertex_x => 1, :vertex_y => 1
            end

            it "redirects to the game" do
              response.should redirect_to(game)
            end

            it "flashes an error message" do
              should set_the_flash[:error].to("There was a problem adding the settlement")
            end
          end
        end

        context "when the current_user does not control the player" do
          let(:other_user) { FactoryGirl.build_stubbed(:confirmed_user) }
          before(:each) {player.stub(:user).and_return(other_user)}

          it "redirects to the games index" do
            post :create, :player_id => player, :vertex_x => 1, :vertex_y => 1
            response.should redirect_to(games_url)
          end
        end
      end
    end
  end
end
