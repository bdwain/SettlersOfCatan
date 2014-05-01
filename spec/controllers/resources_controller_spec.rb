require 'spec_helper'

describe ResourcesController do
  context "When Not Logged In" do
    let(:game) {FactoryGirl.build_stubbed(:game)}
    let(:player) {FactoryGirl.build_stubbed(:player)}
    after { response.should redirect_to new_user_session_path }
    it { patch :update_multiple, :player_id => player, :delete => {} }
  end

  context "When Logged In" do
    login

    describe "PATCH update_multiple" do
      context "with an invalid player" do
        before(:each) { Player.should_receive(:find_by_id).and_return(nil) }

        it "redirects to the games index" do
          patch :update_multiple, :player_id => -1, :delete => {}
          response.should redirect_to(games_url)
        end
      end

      context "with a valid player" do
        let(:game) {FactoryGirl.build_stubbed(:game)}
        let(:player) {FactoryGirl.build_stubbed(:player)}
        before(:each) {player.stub(:game).and_return(game)}
        before(:each) { Player.stub(:find_by_id).with(player.id.to_s).and_return(player) }

        context "when the current_user does control the player" do
          before(:each) {player.stub(:user).and_return(@current_user)}

          context "when params[:delete] does not exist" do
            before(:each) do
              player.should_receive(:discard_half_resources?).with(nil).and_return(false)
              patch :update_multiple, :player_id => player, :foo => {"1" => "0", "2" => "4"}
            end

            it "redirects to the game" do
              response.should redirect_to(game)
            end

            it "flashes an error message" do
              should set_the_flash[:error].to("There was a problem discarding the resources")
            end
          end

          context "when params[:delete] exists" do
            let(:params_delete) {{"1" => "4", "2" => "5"}}
            let(:params_delete_as_ints) {{1 => 4, 2 => 5}}

            it "calls player.discard_half_resources? with the params casted to integers" do
              player.should_receive(:discard_half_resources?).with(params_delete_as_ints)
              patch :update_multiple, :player_id => player, :delete => params_delete
            end

            context "when player.discard_half_resources? returns true" do
              before(:each) do
                player.stub(:discard_half_resources?).and_return(true)
                patch :update_multiple, :player_id => player, :delete => params_delete
              end

              it "redirects to the game" do
                response.should redirect_to(game)
              end
            end

            context "when player.discard_half_resources? returns false" do
              before(:each) do
                player.stub(:discard_half_resources?).and_return(false)
                patch :update_multiple, :player_id => player, :delete => params_delete
              end

              it "redirects to the game" do
                response.should redirect_to(game)
              end

              it "flashes an error message" do
                should set_the_flash[:error].to("There was a problem discarding the resources")
              end
            end
          end
        end

        context "when the current_user does not control the player" do
          let(:other_user) { FactoryGirl.build_stubbed(:confirmed_user) }
          before(:each) {player.stub(:user).and_return(other_user)}

          it "redirects to the games index" do
            patch :update_multiple, :player_id => player, :delete => {}
            response.should redirect_to(games_url)
          end
        end
      end
    end
  end
end
