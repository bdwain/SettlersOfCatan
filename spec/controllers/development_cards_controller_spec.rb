require 'spec_helper'

describe DevelopmentCardsController do
  context "When Not Logged In" do
    let(:game) {FactoryGirl.build_stubbed(:game)}
    let(:player) {FactoryGirl.build_stubbed(:player)}
    after { expect(response).to redirect_to new_user_session_path }
    it { post :create, :player_id => player}
  end

  context "When Logged In" do
    login
    describe "POST create" do
      context "with an invalid player" do
        before(:each) { expect(Player).to receive(:find_by_id).and_return(nil) }
        it "redirects to the games index" do
          post :create, :player_id => -1
          expect(response).to redirect_to(games_url)
        end
      end

      context "with a valid player" do
        let(:game) {FactoryGirl.build_stubbed(:game)}
        let(:player) {FactoryGirl.build_stubbed(:player)}
        before(:each) {allow(player).to receive(:game).and_return(game)}
        before(:each) { expect(Player).to receive(:find_by_id).with(player.id.to_s).and_return(player) }

        context "when the current_user does control the player" do
          before(:each) {allow(player).to receive(:user).and_return(@current_user)}

          it "calls player.buy_development_card?" do
            expect(player).to receive(:buy_development_card?)
            post :create, :player_id => player
          end

          context "when player.buy_development_card? returns true" do
            before(:each) do
              allow(player).to receive(:buy_development_card?).and_return(true)
              post :create, :player_id => player
            end

            it "redirects to the game" do
              expect(response).to redirect_to(game)
            end
          end

          context "when player.buy_development_card? returns false" do
            before(:each) do
              allow(player).to receive(:buy_development_card?).and_return(false)
              post :create, :player_id => player
            end

            it "redirects to the game" do
              expect(response).to redirect_to(game)
            end

            it "flashes an error message" do
              should set_the_flash[:error].to("There was a problem buying the development card")
            end
          end
        end

        context "when the current_user does not control the player" do
          let(:other_user) { FactoryGirl.build_stubbed(:confirmed_user) }
          before(:each) {allow(player).to receive(:user).and_return(other_user)}

          it "redirects to the games index" do
            post :create, :player_id => player
            expect(response).to redirect_to(games_url)
          end
        end
      end
    end
  end
end
